from __future__ import print_function

import logging
import os
import sys

# 3rd party
# from django.apps import AppConfig, apps
import django
import django.conf

# project
from ddtrace.contrib.django.db import patch_db
from ddtrace.contrib.django.conf import settings
from ddtrace.contrib.django.cache import patch_cache
from ddtrace.contrib.django.templates import patch_template
from ddtrace.contrib.django.middleware import insert_exception_middleware, insert_trace_middleware

from ddtrace.ext import AppTypes


log = logging.getLogger(__name__)

def django16_ready():
    print('# Configure ddtrace.contrib.django for Django 1.6', file=sys.stderr)

    tracer = settings.TRACER

    if settings.TAGS:
        tracer.set_tags(settings.TAGS)

    # configure the tracer instance
    # TODO[manu]: we may use configure() but because it creates a new
    # AgentWriter, it breaks all tests. The configure() behavior must
    # be changed to use it in this integration
    tracer.enabled = settings.ENABLED
    tracer.writer.api.hostname = settings.AGENT_HOSTNAME
    tracer.writer.api.port = settings.AGENT_PORT

    # define the service details
    tracer.set_service_info(
        app='django',
        app_type=AppTypes.web,
        service=settings.DEFAULT_SERVICE,
    )

    if settings.AUTO_INSTRUMENT:
        # trace Django internals
        insert_trace_middleware()
        insert_exception_middleware()

        if settings.INSTRUMENT_TEMPLATE:
            try:
                patch_template(tracer)
            except Exception:
                log.exception('error patching Django template rendering')

        if settings.INSTRUMENT_DATABASE:
            try:
                patch_db(tracer)
            except Exception:
                log.exception('error patching Django database connections')

        if settings.INSTRUMENT_CACHE:
            try:
                patch_cache(tracer)
            except Exception:
                log.exception('error patching Django cache')

        # Instrument rest_framework app to trace custom exception handling.
        if 'rest_framework' in django.conf.settings.INSTALLED_APPS:
            try:
                from ddtrace.contrib.django.restframework import patch_restframework
                patch_restframework(tracer)
            except Exception:
                log.exception('error patching rest_framework app')


if os.environ.get('APM') == 'ddtrace' and django.VERSION[:2] < (1, 7):
    django16_ready()
