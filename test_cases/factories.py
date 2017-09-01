import factory
from factory.fuzzy import (
    FuzzyText,
    FuzzyChoice
)
from server.models import (
    db,
    Host,
    Command,
    Service,
    Workspace,
    Credential,
    Vulnerability,
    EntityMetadata,
)


class FaradayFactory(factory.alchemy.SQLAlchemyModelFactory):

    # id = factory.Sequence(lambda n: n)
    pass


class WorkspaceFactory(FaradayFactory):

    name = FuzzyText()

    class Meta:
        model = Workspace
        sqlalchemy_session = db.session


class WorkspaceObjectFactory(FaradayFactory):
    workspace = factory.SubFactory(WorkspaceFactory)


class HostFactory(WorkspaceObjectFactory):
    ip = factory.Faker('ipv4')
    description = FuzzyText()
    os = FuzzyChoice(['Linux', 'Windows', 'OSX', 'Android', 'iOS'])

    class Meta:
        model = Host
        sqlalchemy_session = db.session


class EntityMetadataFactory(WorkspaceObjectFactory):
    couchdb_id = factory.Sequence(lambda n: '{0}.1.2'.format(n))

    class Meta:
        model = EntityMetadata
        sqlalchemy_session = db.session


class ServiceFactory(WorkspaceObjectFactory):
    name = FuzzyText()
    description = FuzzyText()
    ports = FuzzyChoice(['443', '80', '22'])
    host = factory.SubFactory(HostFactory)

    class Meta:
        model = Service
        sqlalchemy_session = db.session


class VulnerabilityFactory(WorkspaceObjectFactory):

    name = FuzzyText()
    description = FuzzyText()
    host = factory.SubFactory(HostFactory)
    entity_metadata = factory.SubFactory(EntityMetadataFactory)
    service = factory.SubFactory(ServiceFactory)
    workspace = factory.SubFactory(WorkspaceFactory)
    vuln_type = FuzzyChoice(['Vulnerability', 'VulnerabilityWeb'])
    attachments = '[]'
    policyviolations = '[]'
    refs = '[]'

    class Meta:
        model = Vulnerability
        sqlalchemy_session = db.session


class CredentialFactory(WorkspaceObjectFactory):
    username = FuzzyText()
    password = FuzzyText()

    class Meta:
        model = Credential
        sqlalchemy_session = db.session


class CommandFactory(WorkspaceObjectFactory):
    command = FuzzyText()

    class Meta:
        model = Command
        sqlalchemy_session = db.session
