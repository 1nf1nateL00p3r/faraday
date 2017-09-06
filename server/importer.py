# Faraday Penetration Test IDE
# Copyright (C) 2016  Infobyte LLC (http://www.infobytesec.com/)
# See the file 'doc/LICENSE' for the license information
import os
import sys
import json
import datetime
from binascii import unhexlify

import requests
from IPy import IP
from flask_script import Command as FlaskScriptCommand
from passlib.utils.binary import ab64_encode
from restkit.errors import RequestError, Unauthorized
from tqdm import tqdm

import server.config
import server.couchdb
import server.database
import server.models
import server.utils.logger
from server.models import (
    db,
    EntityMetadata,
    Credential,
    Host,
    Service,
    Reference,
    Command,
    Workspace,
    Hostname,
    Vulnerability,
    VulnerabilityWeb,
    User,
    PolicyViolation,
    Task,
    TaskTemplate,
    Methodology,
    MethodologyTemplate,
    ExecutiveReport,
    VulnerabilityTemplate,
    ReferenceTemplate,
    License,
    Comment,
    CommentObject,
)
from server.utils.database import get_or_create
from server.web import app

COUCHDB_USER_PREFIX = 'org.couchdb.user:'
COUCHDB_PASSWORD_PREFIX = '-pbkdf2-'


logger = server.utils.logger.get_logger(__name__)
session = db.session

OBJ_TYPES = [
            (1, 'Host'),
            (1, 'EntityMetadata'),
            (1, 'Note'),
            (1, 'CommandRunInformation'),
            (1, 'TaskGroup'),
            (1, 'Task'),
            (1, 'Workspace'),
            (1, 'Reports'),
            (1, 'Communication'),
            (2, 'Service'),
            (2, 'Credential'),
            (2, 'Vulnerability'),
            (2, 'VulnerabilityWeb'),
            (3, 'Service'),
            (4, 'Credential'),  # Level 4 is for interface
            (4, 'Vulnerability'),
            (4, 'VulnerabilityWeb'),
        ]

def get_children_from_couch(workspace, parent_couchdb_id, child_type, level):
    """
    Performance for temporary views suck, so this method uploads a view and queries it instead

    :param workspace: workspace to upload the view
    :param parent_couchdb_id: ID of the parent document
    :param child_type: type of the child obj we're looking for
    :param level: level of the child obj we're looking for, must match those in OBJ_TYPES
    :return:
    """
    if (level, child_type) not in OBJ_TYPES:
        logger.warn('Unable to retrieve children of type {0} at level {1}'.format(child_type, level))
        return []

    couch_url = "http://{username}:{password}@{hostname}:{port}/{workspace_name}/".format(
        username=server.config.couchdb.user,
        password=server.config.couchdb.password,
        hostname=server.config.couchdb.host,
        port=server.config.couchdb.port,
        workspace_name=workspace.name,
    )

    # create the new view
    view_url = "{}_design/importer".format(couch_url)
    view_data = {
        "views": {
            "children_by_parent_and_type": {
                "map": "function(doc) { id_parent = doc._id.split('.').slice(0, -1).join('.');"
                "key = [id_parent,doc.type]; emit(key, doc); }"
            }
        }
    }

    try:
        r = requests.put(view_url, json=view_data)
    except requests.exceptions.RequestException as e:
        logger.warn(e)
        return []

    # and now, finally query it!
    couch_url += "_design/importer/_view/children_by_parent_and_type?" \
                 "startkey=[\"{parent_id}\",\"{child_type}\"]&" \
                 "endkey=[\"{parent_id}\",\"{child_type}\"]".format(
        parent_id=parent_couchdb_id,
        child_type=child_type,
    )

    try:
        r = requests.get(couch_url)
    except requests.exceptions.RequestException as e:
        logger.warn(e)
        return []

    return r.json()['rows']


class EntityNotFound(Exception):
    def __init__(self, entity_id):
        super(EntityNotFound, self).__init__("Entity (%s) wasn't found" % entity_id)


class EntityMetadataImporter(object):

    def update_from_document(self, document, workspace, level=None, couchdb_relational_map=None):
        entity, created = get_or_create(session, EntityMetadata, couchdb_id=document.get('_id'))
        metadata = document.get('metadata', dict())
        entity.update_time = metadata.get('update_time', None)
        entity.update_user = metadata.get('update_user', None)
        entity.update_action = metadata.get('update_action', None)
        entity.creator = metadata.get('creator', None)
        entity.owner = metadata.get('owner', None)
        entity.create_time = metadata.get('create_time', None)
        entity.update_controller_action = metadata.get('update_controller_action', None)
        entity.revision = document.get('_rev')
        entity.document_type = document.get('type')
        entity.command_id = metadata.get('command_id', None)

        if entity.create_time is not None:
            entity.create_time = self.__truncate_to_epoch_in_seconds(entity.create_time)

        yield entity

    def __truncate_to_epoch_in_seconds(self, timestamp):
        """ In a not so elegant fashion, identifies and truncate
        epoch timestamps expressed in milliseconds to seconds"""
        limit = 32503680000  # 01 Jan 3000 00:00:00 GMT
        if timestamp > limit:
            return timestamp / 1000
        else:
            return timestamp


def check_ip_address(ip_str):
    if not ip_str:
     return False
    if ip_str == '0.0.0.0':
        return False
    if ip_str == '0000:0000:0000:0000:0000:0000:0000:0000':
        return False
    if ip_str == '0000:0000:0000:0000:0000:0000:0000:0001':
        return False
    try:
        IP(ip_str)
    except ValueError:
        return False
    return True


class HostImporter(object):
    """
        Class interface was removed in the new model.
        We will merge the interface data with the host.
        For ports we will create new services for open ports
        if it was not previously created.
    """

    def retrieve_ips_from_host_document(self, document):
        """

        :param document: json document from couchdb with host data
        :return: str with ip or name if no valid ip was found.
        """
        try:
            IP(document.get('name'))  # this will raise ValueError on invalid IPs
            yield document.get('name')
        except ValueError:
            host_ip = document.get('ipv4')
            created_ipv4 = False
            created_ipv6 = False
            if check_ip_address(host_ip):
                yield host_ip
                created_ipv4 = True
            host_ip = document.get('ipv6')
            if check_ip_address(host_ip):
                yield host_ip
            if not created_ipv4 or not created_ipv6:
                # sometimes the host lacks the ip.
                yield document.get('name')
            if created_ipv4 and created_ipv6:
                logger.warn('Two host will be created one with ipv4 and another one with ipv6. Couch id is {0}'.format(document.get('_id')))

    def update_from_document(self, document, workspace, level=None, couchdb_relational_map=None):
        hosts = []
        host_ips = [name_or_ip for name_or_ip in self.retrieve_ips_from_host_document(document)]
        interfaces = self.host_interfaces_from_couch(workspace, document.get('_id'))
        for interface in interfaces:
            interface = interface['value']
            if check_ip_address(interface['ipv4']['address']):
                interface_ip = interface['ipv4']['address']
                host, created = get_or_create(session, Host, ip=interface_ip, workspace=workspace)
                host.default_gateway_ip = interface['ipv4']['gateway']
                self.merge_with_host(host, interface, workspace)
                hosts.append(host)
            if check_ip_address(interface['ipv6']['address']):
                interface_ip = interface['ipv6']['address']
                host, created = get_or_create(session, Host, ip=interface_ip, workspace=workspace)
                host.default_gateway_ip = interface['ipv6']['gateway']
                self.merge_with_host(host, interface, workspace)
                hosts.append(host)
        if not hosts:
            # if not host were created after inspecting interfaces
            # we create a host with "name" as ip to avoid losing hosts.
            # some hosts lacks of interface
            for name_or_ip in host_ips:
                host, created = get_or_create(session, Host, ip=name_or_ip, workspace=workspace)
                hosts.append(host)

        if len(hosts) > 1:
            logger.warning('Total hosts found {0} for couchdb id {1}'.format(len(hosts), document.get('_id')))

        for host in hosts:
            # we update or set other host attributes in this cycle
            # Ticket #3387: if the 'os' field is None, we default to 'unknown
            if not document.get('os'):
                document['os'] = 'unknown'

            default_gateway = document.get('default_gateway', None)

            host.description = document.get('description')
            host.os = document.get('os')
            host.default_gateway_ip = default_gateway and default_gateway[0]
            host.default_gateway_mac = default_gateway and default_gateway[1]
            host.owned = document.get('owned', False)
            host.workspace = workspace
            yield host

    def host_interfaces_from_couch(self, workspace, host_couchdb_id):
        couch_url = "http://{username}:{password}@{hostname}:{port}/{workspace_name}/_temp_view?include_docs=true".format(
                    username=server.config.couchdb.user,
                    password=server.config.couchdb.password,
                    hostname=server.config.couchdb.host,
                    port=server.config.couchdb.port,
                    workspace_name=workspace.name
                )
        data = {
            "map": "function(doc) { if(doc.type == '%s' && doc._id.split('.').slice(0, 1).join('.') == '%s') emit(null, doc); }" % (
            'Interface', host_couchdb_id)
        }

        r = requests.post(couch_url, json=data)
        try:
            return r.json()['rows']
        except Exception as ex:
            print('sadsa')

    def merge_with_host(self, host, interface, workspace):
        if interface['mac']:
            host.mac = interface['mac']
        if interface['owned']:
            host.owned = interface['owned']

        #host.default_gateway_mac
        if interface['network_segment']:
            host.net_segment = interface['network_segment']
        if interface['description']:
            host.description += '\n Interface data: {0}'.format(interface['description'])
        if type(interface['hostnames']) in (str, unicode):
            interface['hostnames'] = [interface['hostnames']]

        for hostname_str in interface['hostnames']:
            if not hostname_str:
                # skip empty hostnames
                continue
            hostname, created = get_or_create(
                session,
                Hostname,
                name=hostname_str,
                host=host,
                workspace=workspace
            )
        host.owned = host.owned or interface['owned']
        return host


class ServiceImporter(object):
    DOC_TYPE = 'Service'

    def update_from_document(self, document, workspace, level=None, couchdb_relational_map=None):
        #  service was always below interface, not it's below host.
        try:
            parent_id = document['parent'].split('.')[0]
        except KeyError:
            # some services are missing the parent key
            parent_id = document['_id'].split('.')[0]
        host, created = get_or_create(session, Host, id=couchdb_relational_map[parent_id])
        ports = document.get('ports')
        if len(ports) > 2:
            logger.warn('More than one port found in services!')
        for port in ports:
            service, created = get_or_create(session,
                                             Service,
                                             name=document.get('name'),
                                             port=port,
                                             host=host)
            service.description = document.get('description')
            service.owned = document.get('owned', False)
            service.banner = document.get('banner')
            service.protocol = document.get('protocol')
            if not document.get('status'):
                logger.warning('Service {0} with empty status. Using open as status'.format(document['_id']))
                document['status'] = 'open'
            status_mapper = {
                'open': 'open',
                'closed': 'closed',
                'filtered': 'filtered',
                'open|filtered': 'filtered'
            }
            service.status = status_mapper[document.get('status')]
            service.version = document.get('version')
            service.workspace = workspace

            yield service


class VulnerabilityImporter(object):
    DOC_TYPE = ['Vulnerability', 'VulnerabilityWeb']

    def update_from_document(self, document, workspace, level=None, couchdb_relational_map=None):
        couch_parent_id = document.get('parent', None)
        if not couch_parent_id:
            couch_parent_id = '.'.join(document['_id'].split('.')[:-1])
        parent_id = couchdb_relational_map[couch_parent_id]
        if level == 2:
            parent = session.query(Host).filter_by(id=parent_id).first()
        if level == 4:
            parent = session.query(Service).filter_by(id=parent_id).first()
        if document['type'] == 'VulnerabilityWeb':
            vulnerability, created = get_or_create(
                session,
                VulnerabilityWeb,
                name=document.get('name'),
                description=document.get('desc'),
                service_id=parent.id,
            )
        if document['type'] == 'Vulnerability':
            vuln_params = {
                'name': document.get('name'),
                'description': document.get('desc')
            }
            if type(parent) == Host:
                vuln_params.update({'host_id': parent.id})
            elif type(parent) == Service:
                vuln_params.update({'service_id': parent.id})
            vulnerability, created = get_or_create(
                session,
                Vulnerability,
                **vuln_params
            )

        vulnerability.confirmed = document.get('confirmed', False) or False
        vulnerability.data = document.get('data')
        vulnerability.easeofresolution = document.get('easeofresolution')
        vulnerability.resolution = document.get('resolution')
        mapped_severity = {
            'med': 'medium',
            'critical': 'critical',
            'high':'high',
            'low': 'low',
            'info': 'informational',
            'unclassified': 'unclassified',
        }
        vulnerability.severity = mapped_severity[document.get('severity')]
        vulnerability.owned = document.get('owned', False)
        #vulnerability.attachments = json.dumps(document.get('_attachments', {}))
        vulnerability.impact_accountability = document.get('impact', {}).get('accountability')
        vulnerability.impact_availability = document.get('impact', {}).get('availability')
        vulnerability.impact_confidentiality = document.get('impact', {}).get('confidentiality')
        vulnerability.impact_integrity = document.get('impact', {}).get('integrity')
        if document['type'] == 'VulnerabilityWeb':
            vulnerability.method = document.get('method')
            vulnerability.path = document.get('path')
            vulnerability.pname = document.get('pname')
            vulnerability.query = document.get('query')
            vulnerability.request = document.get('request')
            vulnerability.response = document.get('response')
            vulnerability.website = document.get('website')
            params = document.get('params', u'')
            if isinstance(params, (list, tuple)):
                vulnerability.parameters = (u' '.join(params)).strip()
            else:
                vulnerability.parameters = params if params is not None else u''
        status_map = {
            'opened': 'open',
            'closed': 'closed',
        }
        status = status_map[document.get('status', 'opened')]
        vulnerability.status = status
        vulnerability.workspace = workspace

        self.add_references(document, vulnerability, workspace)
        self.add_policy_violations(document, vulnerability, workspace)
        yield vulnerability

    def add_policy_violations(self, document, vulnerability, workspace):
        for policy_violation in document.get('policyviolations', []):
            get_or_create(
                session,
                PolicyViolation,
                name=policy_violation,
                workspace=workspace,
                vulnerability=vulnerability
            )

    def add_references(self, document, vulnerability, workspace):
        for ref in document.get('refs', []):
            get_or_create(
                session,
                Reference,
                name=ref,
                workspace=workspace,
                vulnerability=vulnerability
            )


class CommandImporter(object):
    DOC_TYPE = 'CommandRunInformation'

    def update_from_document(self, document, workspace, level=None, couchdb_relational_map=None):
        start_date = datetime.datetime.fromtimestamp(document.get('itime'))

        command, instance = get_or_create(
                session,
                Command,
                command=document.get('command', None),
                start_date=start_date,
        )
        if document.get('duration'):
            command.end_date = start_date + datetime.timedelta(seconds=document.get('duration'))

        command.command = document.get('command', None)
        command.ip = document.get('ip', None)
        command.hostname = document.get('hostname', None)
        command.params = document.get('params', None)
        command.user = document.get('user', None)
        command.workspace = workspace

        yield command


class NoteImporter(object):
    DOC_TYPE = 'Note'

    def update_from_document(self, document, workspace, level=None, couchdb_relational_map=None):
        note = Note()
        note.name = document.get('name')
        note.text = document.get('text', None)
        note.description = document.get('description', None)
        note.owned = document.get('owned', False)
        yield note


class CredentialImporter(object):
    DOC_TYPE = 'Cred'

    def update_from_document(self, document, workspace, level=None, couchdb_relational_map=None):
        host = None
        service = None
        if level == 2:
            parent_id = couchdb_relational_map[document['_id'].split('.')[0]]
            host = session.query(Host).filter_by(id=parent_id).first()
        if level == 4:
            parent_id = couchdb_relational_map['.'.join(document['_id'].split('.')[:3])]
            service = session.query(Service).filter_by(id=parent_id).first()
        if not host and not service:
            raise Exception('Missing host or service for credential {0}'.format(document['_id']))
        credential, created = get_or_create(session, Credential, username=document.get('username'), host=host, service=service)
        credential.password = document.get('password', None)
        credential.owned = document.get('owned', False)
        credential.description = document.get('description', None)
        credential.name = document.get('name', None)
        credential.workspace = workspace
        yield credential


class WorkspaceImporter(object):
    DOC_TYPE = 'Workspace'

    def update_from_document(self, document, workspace, level=None, couchdb_relational_map=None):
        workspace.description = document.get('description')
        if document.get('duration') and document.get('duration')['start']:
            workspace.start_date = datetime.datetime.fromtimestamp(float(document.get('duration')['start'])/1000)
        if document.get('duration') and document.get('duration')['end']:
            workspace.end_date = datetime.datetime.fromtimestamp(float(document.get('duration')['end'])/1000)
        workspace.scope = document.get('scope')
        yield workspace


class MethodologyImporter(object):
    def update_from_document(self, document, workspace, level=None, couchdb_relational_map=None):
        if document.get('group_type') == 'template':
            methodology, created = get_or_create(session, MethodologyTemplate, name=document.get('name'))
            methodology.workspace = workspace
            yield methodology

        if document.get('group_type') == 'instance':
            methodology, created = get_or_create(session, Methodology, name=document.get('name'))
            methodology.workspace = workspace
            yield methodology
#        methodology.


class TaskImporter(object):

    def update_from_document(self, document, workspace, level=None, couchdb_relational_map=None):
        try:
            methodology_id = couchdb_relational_map[document.get('group_id')]
        except KeyError:
            logger.warn('Could not found methodology with id {0}'.format(document.get('group_id')))
            return []
        methodology = session.query(Methodology).filter_by(id=methodology_id).first()
        task_class = Task
        if not methodology:
            methodology = session.query(MethodologyTemplate).filter_by(id=methodology_id).first()
            task_class = TaskTemplate
        task, created = get_or_create(session, task_class, name=document.get('name'))
        if task_class == TaskTemplate:
            task.template = methodology
        else:
            task.methodology = methodology
            task.workspace = workspace
        task.description = document.get('description')
        task.assigned_to = session.query(User).filter_by(username=document.get('username')).first()
        mapped_status = {
            'New': 'new',
            'In Progress': 'in progress',
            'Review': 'review',
            'Completed': 'completed'
        }
        task.status = mapped_status[document.get('status')]
        #tags
        #task.due_date = datetime.datetime.fromtimestamp(document.get('due_date'))
        return [task]


class ReportsImporter(object):

    def update_from_document(self, document, workspace, level=None, couchdb_relational_map=None):
        report, created = get_or_create(session, ExecutiveReport, name=document.get('name'))
        report.template_name = document.get('template_name', 'generic_default.docx')
        report.title = document.get('title')
        report.status = document.get('status')
        # TODO: add tags
        report.conclusions = document.get('conclusions')
        report.summary = document.get('summary')
        report.recommendations = document.get('recommendations')
        report.enterprise = document.get('enterprise')
        report.summary = document.get('summary')
        report.scope = document.get('scope')
        report.objectives = document.get('objectives')
        report.grouped = document.get('grouped', False)
        report.workspace = workspace
        yield report


class CommunicationImporter(object):
    def update_from_document(self, document, workspace, level=None, couchdb_relational_map=None):
        comment, created = get_or_create(
            session,
            Comment,
            text=document.get('text'),
            workspace=workspace)

        get_or_create(
            session,
            CommentObject,
            object_id=workspace.id,
            object_type='Workspace',
            comment=comment,
        )
        yield comment

class FaradayEntityImporter(object):
    # Document Types: [u'Service', u'Communication', u'Vulnerability', u'CommandRunInformation', u'Reports', u'Host', u'Workspace']

    def parse(self, document):
        """Get an instance of a DAO object given a document"""
        importer_class = self.get_importer_from_document(document)
        if importer_class is not None:
            importer = importer_class()
            entity = importer.update_from_document(document)
            metadata = EntityMetadataImporter().update_from_document(document)
            entity.entity_metadata = metadata
            return importer, entity
        return None, None

    def get_importer_from_document(self, doc_type):
        logger.info('Getting class importer for {0}'.format(doc_type))
        importer_class_mapper = {
            'EntityMetadata': EntityMetadataImporter,
            'Host': HostImporter,
            'Service': ServiceImporter,
            'Note': NoteImporter,
            'Credential': CredentialImporter,
            'CommandRunInformation': CommandImporter,
            'Workspace': WorkspaceImporter,
            'Vulnerability': VulnerabilityImporter,
            'VulnerabilityWeb': VulnerabilityImporter,
            'TaskGroup': MethodologyImporter,
            'Task': TaskImporter,
            'Reports': ReportsImporter,
            'Communication': CommunicationImporter
        }
        importer_self = importer_class_mapper.get(doc_type, None)
        if not importer_self:
            raise NotImplementedError('Class importer for {0} not implemented'.format(doc_type))
        return importer_self


class ImportCouchDBUsers(FlaskScriptCommand):

    def modular_crypt_pbkdf2_sha1(self, checksum, salt, iterations=1000):
        return '$pbkdf2${iterations}${salt}${checksum}'.format(
            iterations=iterations,
            salt=ab64_encode(salt),
            checksum=ab64_encode(unhexlify(checksum)),
        )

    def convert_couchdb_hash(self, original_hash):
        if not original_hash.startswith(COUCHDB_PASSWORD_PREFIX):
            # Should be a plaintext password
            return original_hash
        checksum, salt, iterations = original_hash[
            len(COUCHDB_PASSWORD_PREFIX):].split(',')
        iterations = int(iterations)
        return self.modular_crypt_pbkdf2_sha1(checksum, salt, iterations)

    def get_hash_from_document(self, doc):
        scheme = doc.get('password_scheme', 'unset')
        if scheme != 'pbkdf2':
            # Flask Security will encrypt the password next time the user logs in.
            logger.warning('Found user {0} without password.'.format(doc.get('name')))
            return 'changeme'
        return self.modular_crypt_pbkdf2_sha1(doc['derived_key'], doc['salt'],
                                         doc['iterations'])

    def parse_all_docs(self, doc):
        return [row['doc'] for row in doc['rows']]

    def get_users_and_admins(self):
        admins_url = "http://{username}:{password}@{hostname}:{port}/{path}".format(
                    username=server.config.couchdb.user,
                    password=server.config.couchdb.password,
                    hostname=server.config.couchdb.host,
                    port=server.config.couchdb.port,
                    path='_config/admins'
        )

        users_url = "http://{username}:{password}@{hostname}:{port}/{path}".format(
                    username=server.config.couchdb.user,
                    password=server.config.couchdb.password,
                    hostname=server.config.couchdb.host,
                    port=server.config.couchdb.port,
                    path='_users/_all_docs?include_docs=true'
        )
        admins = requests.get(admins_url).json()
        users = requests.get(users_url).json()
        return users, admins

    def import_admins(self, admins):
        # Import admin users
        for (username, password) in admins.items():
            logger.info('Creating user {0}'.format(username))
            if not db.session.query(User).filter_by(username=username).first():
                app.user_datastore.create_user(
                    username=username,
                    email=username + '@test.com',
                    password=self.convert_couchdb_hash(password),
                    is_ldap=False
                )

    def import_users(self, all_users, admins):
        # Import non admin users
        for user in all_users['rows']:
            user = user['doc']
            if not user['_id'].startswith(COUCHDB_USER_PREFIX):
                # It can be a view or something other than a user
                continue
            if user['name'] in admins.keys():
                # This is an already imported admin user, skip
                continue
            logger.info('Importing {0}'.format(user['name']))
            if not db.session.query(User).filter_by(username=user['name']).first():
                app.user_datastore.create_user(
                    username=user['name'],
                    email=user['name'] + '@test.com',
                    password=self.get_hash_from_document(user),
                    is_ldap=False
                )

    def run(self):
        all_users, admins = self.get_users_and_admins()
        self.import_users(all_users, admins)
        self.import_admins(admins)
        db.session.commit()



class ImportVulnerabilityTemplates(FlaskScriptCommand):

    def run(self):
        cwe_url = "http://{username}:{password}@{hostname}:{port}/{path}".format(
            username=server.config.couchdb.user,
            password=server.config.couchdb.password,
            hostname=server.config.couchdb.host,
            port=server.config.couchdb.port,
            path='cwe/_all_docs?include_docs=true'
        )
        cwes = requests.get(cwe_url).json()['rows']
        for cwe in cwes:
            document = cwe['doc']
            mapped_exploitation = {
                'critical': 'critical',
                'med': 'medium',
                'high':'high',
                'low': 'low',
                'info': 'informational',
            'unclassified': 'unclassified',
            }
            vuln_template, created = get_or_create(session,
                                                   VulnerabilityTemplate,
                                                   name=document.get('name'),
                                                   severity=mapped_exploitation[document.get('exploitation')],
                                                   description=document.get('description'))
            vuln_template.resolution = document.get('resolution')
            for ref_doc in document['references']:
                get_or_create(session,
                             ReferenceTemplate,
                             vulnerability=vuln_template,
                             name=ref_doc)


class ImportLicense(FlaskScriptCommand):

    def run(self):
        cwe_url = "http://{username}:{password}@{hostname}:{port}/{path}".format(
            username=server.config.couchdb.user,
            password=server.config.couchdb.password,
            hostname=server.config.couchdb.host,
            port=server.config.couchdb.port,
            path='faraday_licenses/_all_docs?include_docs=true'
        )
        licenses = requests.get(cwe_url).json()['rows']
        for license in licenses:
            document = license['doc']

            license_obj, created = get_or_create(session,
                                                   License,
                                                   product=document.get('product'),
                                                   start_date=datetime.datetime.strptime(document['start'], "%Y-%m-%dT%H:%M:%S.%fZ"),
                                                   end_date=datetime.datetime.strptime(document['end'], "%Y-%m-%dT%H:%M:%S.%fZ"),
                                                   notes=document.get('notes'),
                                                   type=document.get('lictype')
                                                   )


class ImportCouchDB(FlaskScriptCommand):
    def _open_couchdb_conn(self):
        try:
            couchdb_server_conn = server.couchdb.CouchDBServer()
            workspaces_list = couchdb_server_conn.list_workspaces()

        except RequestError:
            logger.error(u"CouchDB is not running at {}. Check faraday-server's"\
                " configuration and make sure CouchDB is running".format(
                server.couchdb.get_couchdb_url()))
            sys.exit(1)

        except Unauthorized:
            logger.error(u"Unauthorized access to CouchDB. Make sure faraday-server's"\
                " configuration file has CouchDB admin's credentials set")
            sys.exit(1)

        return couchdb_server_conn, workspaces_list

    def run(self):
        """
            Main entry point for couchdb import
        """
        license_import = ImportLicense()
        license_import.run()
        vuln_templates_import = ImportVulnerabilityTemplates()
        vuln_templates_import.run()
        users_import = ImportCouchDBUsers()
        users_import.run()
        couchdb_server_conn, workspaces_list = self._open_couchdb_conn()

        for workspace_name in workspaces_list:
            logger.info(u'Setting up workspace {}'.format(workspace_name))

            if not server.couchdb.server_has_access_to(workspace_name):
                logger.error(u"Unauthorized access to CouchDB. Make sure faraday-server's"\
                             " configuration file has CouchDB admin's credentials set")
                sys.exit(1)

            self.import_workspace_into_database(workspace_name)

    def get_objs(self, host, obj_type, level):
        if obj_type == 'Credential':
            obj_type = 'Cred'
        data = {
            "map": "function(doc) { if(doc.type == '%s' && doc._id.split('.').length == %d) emit(null, doc); }" % (obj_type, level)
        }

        r = requests.post(host, json=data)

        return r.json()

    def verify_import_data(self, couchdb_relational_map, couchdb_removed_objs, workspace):
        all_docs_url = "http://{username}:{password}@{hostname}:{port}/{workspace_name}/_all_docs?include_docs=true".format(
                    username=server.config.couchdb.user,
                    password=server.config.couchdb.password,
                    hostname=server.config.couchdb.host,
                    port=server.config.couchdb.port,
                    workspace_name=workspace.name
        )
        all_ids = map(lambda x: x['doc']['_id'], requests.get(all_docs_url).json()['rows'])
        if len(all_ids) != len(couchdb_relational_map.keys()) + len(couchdb_removed_objs):
            missing_objs_filename = os.path.join(os.path.expanduser('~/.faraday'), 'logs', 'import_missing_objects_{0}.json'.format(workspace.name))
            missing_ids = set(all_ids) - set(couchdb_relational_map.keys()).union(couchdb_removed_objs)
            objs_diff = []
            logger.info('Downloading missing couchdb docs')
            for missing_id in tqdm(missing_ids):
                doc_url = 'http://{username}:{password}@{hostname}:{port}/{workspace_name}/{doc_id}'.format(
                    username=server.config.couchdb.user,
                    password=server.config.couchdb.password,
                    hostname=server.config.couchdb.host,
                    port=server.config.couchdb.port,
                    workspace_name=workspace.name,
                    doc_id=missing_id
                )
                not_imported_obj = requests.get(doc_url).json()
                filter_keys = ['views', 'validate_doc_update']
                if not any(map(lambda x: x not in filter_keys, not_imported_obj.keys())):
                    # we filter custom views, validation funcs, etc
                    logger.warning(
                        'Not all objects were imported. Saving difference to file {0}'.format(missing_objs_filename))
                    objs_diff.append(not_imported_obj)

                    with open(missing_objs_filename, 'w') as missing_objs_file:
                        missing_objs_file.write(json.dumps(objs_diff))

    def import_workspace_into_database(self, workspace_name):

        faraday_importer = FaradayEntityImporter()
        workspace, created = get_or_create(session, Workspace, name=workspace_name)
        session.commit()

        couch_url = "http://{username}:{password}@{hostname}:{port}/{workspace_name}/_temp_view?include_docs=true".format(
                    username=server.config.couchdb.user,
                    password=server.config.couchdb.password,
                    hostname=server.config.couchdb.host,
                    port=server.config.couchdb.port,
                    workspace_name=workspace_name
                )

        # obj_types are tuples. the first value is the level on the tree
        # for the desired obj.
        obj_types = OBJ_TYPES
        couchdb_relational_map = {}
        couchdb_removed_objs = set()
        removed_objs = ['Interface']
        for level, obj_type in obj_types:
            obj_importer = faraday_importer.get_importer_from_document(obj_type)()
            objs_dict = self.get_objs(couch_url, obj_type, level)
            for raw_obj in tqdm(objs_dict.get('rows', [])):
                # we use no_autoflush since some queries triggers flush and some relationship are missing in the middle
                with session.no_autoflush:
                    raw_obj = raw_obj['value']
                    couchdb_id = raw_obj['_id']

                    for new_obj in obj_importer.update_from_document(raw_obj, workspace, level, couchdb_relational_map):
                        if not new_obj:
                            continue
                        session.commit()
                        if obj_type not in removed_objs:
                            couchdb_relational_map[couchdb_id] = new_obj.id
                        else:
                            couchdb_relational_map[couchdb_id] = new_obj['parent_id']
                        couchdb_removed_objs.add(couchdb_id)
        self.verify_import_data(couchdb_relational_map, couchdb_removed_objs, workspace)
        return created
