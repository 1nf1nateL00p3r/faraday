# Faraday Penetration Test IDE
# Copyright (C) 2016  Infobyte LLC (http://www.infobytesec.com/)
# See the file 'doc/LICENSE' for the license information

import os
import sys
import functools

import twisted.web
from twisted.web.resource import Resource, ForbiddenResource

# Ugly hack to make "flask shell" work. It works because when running via flask
# shell, __file__ will be server/web.py instead of faraday-server.py
if os.path.split(os.path.dirname(__file__))[-1] == 'server':
    path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
    sys.path.append(path)

import server.config

from twisted.internet import ssl, reactor, error
from twisted.web.static import File
from twisted.web.util import Redirect
from twisted.web.wsgi import WSGIResource
from autobahn.twisted.websocket import (
    listenWS
)
import server.config
from server.utils import logger

from server.app import create_app
from server.websocket_factories import (
    WorkspaceServerFactory,
    BroadcastServerProtocol
)

app = create_app()  # creates a Flask(__name__) app
logger = server.utils.logger.get_logger(__name__)


class CleanHttpHeadersResource(Resource, object):
    def render(self, request):
        request.responseHeaders.removeHeader('Server')
        return super(CleanHttpHeadersResource, self).render(request)


class FileWithoutDirectoryListing(File, CleanHttpHeadersResource):
    def directoryListing(self):
        return ForbiddenResource()

    def render(self, request):
        ret = super(FileWithoutDirectoryListing, self).render(request)
        if self.type == 'text/html':
            request.responseHeaders.addRawHeader('Content-Security-Policy',
                                                 'frame-ancestors \'none\'')
            request.responseHeaders.addRawHeader('X-Frame-Options', 'DENY')
        return ret


class FaradayWSGIResource(WSGIResource, object):
    def render(self, request):
        request.responseHeaders.removeHeader('Server')
        return super(FaradayWSGIResource, self).render(request)


class FaradayRedirectResource(Redirect, object):
    def render(self, request):
        request.responseHeaders.removeHeader('Server')
        return super(FaradayRedirectResource, self).render(request)


class WebServer(object):
    UI_URL_PATH = '_ui'
    API_URL_PATH = '_api'
    WEB_UI_LOCAL_PATH = os.path.join(server.config.FARADAY_BASE, 'server/www')

    def __init__(self, enable_ssl=False):
        logger.info('Starting web server at port {0} with bind address {1}. SSL {2}'.format(
            server.config.faraday_server.port,
            server.config.faraday_server.bind_address,
            enable_ssl))
        self.__ssl_enabled = enable_ssl
        self.__config_server()
        self.__build_server_tree()

    def __config_server(self):
        self.__bind_address = server.config.faraday_server.bind_address
        self.__listen_port = int(server.config.faraday_server.port)
        if self.__ssl_enabled:
            self.__listen_port = int(server.config.ssl.port)

    def __load_ssl_certs(self):
        certs = (server.config.ssl.keyfile, server.config.ssl.certificate)
        if not all(certs):
            logger.critical("HTTPS request but SSL certificates are not configured")
            exit(1) # Abort web-server startup
        return ssl.DefaultOpenSSLContextFactory(*certs)

    def __build_server_tree(self):
        self.__root_resource = self.__build_web_resource()
        self.__root_resource.putChild(WebServer.UI_URL_PATH,
                                      self.__build_web_redirect())
        self.__root_resource.putChild(
            WebServer.API_URL_PATH, self.__build_api_resource())

    def __build_web_redirect(self):
        return FaradayRedirectResource('/')

    def __build_web_resource(self):
        return FileWithoutDirectoryListing(WebServer.WEB_UI_LOCAL_PATH)

    def __build_api_resource(self):
        return FaradayWSGIResource(reactor, reactor.getThreadPool(), app)

    def __build_websockets_resource(self):
        websocket_port = int(server.config.faraday_server.websocket_port)
        url = '{0}:{1}'.format(self.__bind_address, websocket_port)
        if self.__ssl_enabled:
            url = 'wss://' + url
        else:
            url = 'ws://' + url
        logger.info(u"Websocket listening at {url}".format(url=url))

        factory = WorkspaceServerFactory(url=url)
        factory.protocol = BroadcastServerProtocol
        return factory

    def run(self):
        site = twisted.web.server.Site(self.__root_resource)
        if self.__ssl_enabled:
            ssl_context = self.__load_ssl_certs()
            self.__listen_func = functools.partial(
                reactor.listenSSL,
                contextFactory=ssl_context)
        else:
            self.__listen_func = reactor.listenTCP

        try:
            # web and static content
            self.__listen_func(
                self.__listen_port, site,
                interface=self.__bind_address)
            # websockets
            listenWS(self.__build_websockets_resource(), interface=self.__bind_address)
            reactor.run()
        except error.CannotListenError as e:
            logger.error(str(e))
            sys.exit(1)
        except Exception as e:
            logger.debug(e)
            logger.error('Something went wrong when trying to setup the Web UI')
            sys.exit(1)
