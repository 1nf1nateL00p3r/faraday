# Faraday Penetration Test IDE
# Copyright (C) 2018  Infobyte LLC (http://www.infobytesec.com/)
# See the file 'doc/LICENSE' for the license information

from Queue import Queue
from multiprocessing import Queue as MultiProcessingQueue
from threading import Thread

import os
import string
import random
import logging
import model.api

from flask import request, abort, jsonify, Blueprint
from werkzeug.utils import secure_filename

from server.utils.logger import get_logger
from server.utils.web import gzipped

from model.controller import ModelController
from model.cli_app import CliApp

from plugins.controller import PluginController
from plugins.manager import PluginManager

from managers.workspace_manager import WorkspaceManager
from managers.mapper_manager import MapperManager

from config.configuration import getInstanceConfiguration
CONF = getInstanceConfiguration()

upload_api = Blueprint('upload_reports', __name__)
logger = logging.getLogger(__name__)
UPLOAD_REPORTS_QUEUE = MultiProcessingQueue()


class RawReportProcessor(Thread):
    def __init__(self):

        super(RawReportProcessor, self).__init__()
        plugin_manager = PluginManager(os.path.join(CONF.getConfigPath(), "plugins"))

        mappers_manager = MapperManager()
        self.pending_actions = Queue()

        model_controller = ModelController(mappers_manager, self.pending_actions)

        workspace_manager = WorkspaceManager(mappers_manager)
        CONF.setMergeStrategy("new")
        model.api.setUpAPIs(model_controller, workspace_manager, 0, 0)
        model_controller.start()

        plugin_controller = PluginController(
            'PluginController',
            plugin_manager,
            mappers_manager,
            self.pending_actions)

        self.cli_import = CliApp(workspace_manager, plugin_controller)

    def run(self):

        while True:
            try:

                workspace, file_path = UPLOAD_REPORTS_QUEUE.get()
                logger.info('Processing raw report {0}'.format(file_path))

                class Arg():
                    def __init__(self):
                        self.workspace = workspace
                        self.filename = file_path

                self.cli_import.run(Arg())
            except KeyboardInterrupt:
                break


@gzipped
@upload_api.route('/v2/ws/<workspace>/upload_report', methods=['POST'])
def file_upload(workspace=None):
    """
    Upload a report file to Server and process that report with Faraday client plugins.
    """

    get_logger(__name__).debug("Importing new plugin report in server...")

    if 'file' not in request.files:
        abort(400)

    report_file = request.files['file']

    if report_file.filename == '':
        abort(400)

    if report_file:

        chars = string.ascii_uppercase + string.digits
        random_prefix = ''.join(random.choice(chars) for x in range(12))
        raw_report_filename = '{0}{1}'.format(random_prefix, secure_filename(report_file.filename))

        file_path = os.path.join(
            CONF.getConfigPath(),
            'uploaded_reports/{0}'.format(raw_report_filename))

        with open(file_path, 'w') as output:
            output.write(report_file.read())

    UPLOAD_REPORTS_QUEUE.put((workspace, file_path))

    return jsonify({"status": "processing"})
