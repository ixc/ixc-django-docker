from __future__ import print_function

import sys

# Everything below was copied from `ddtrace.contrib.django.apps`, with changes
# noted in "IC" comments below, for Django 1.6 compatibility.

import logging

# 3rd party
# IC: Add Django 1.6 compatible fallback `AppConfig` and `apps`.
try:
    from django.apps import AppConfig, apps
except ImportError:
    AppConfig = object
    class apps(object):
        @classmethod
        def is_installed(cls, app):
            import django.conf
            return app in django.conf.settings.INSTALLED_APPS


# project
# IC: Use absolute imports.
from ddtrace.contrib.django.db import patch_db
from ddtrace.contrib.django.conf import settings
from ddtrace.contrib.django.cache import patch_cache
from ddtrace.contrib.django.templates import patch_template
from ddtrace.contrib.django.middleware import insert_exception_middleware, insert_trace_middleware

from ddtrace.ext import AppTypes

log = logging.getLogger(__name__)


class TracerConfig(AppConfig):
    name = 'ddtrace.contrib.django'
    label = 'datadog_django'

    def ready(self):
        """
        Ready is called as soon as the registry is fully populated.
        Tracing capabilities must be enabled in this function so that
        all Django internals are properly configured.
        """
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
            insert_trace_middleware()  # IC: No-op. Too late to patch. This must be done explicitly.
            insert_exception_middleware()  # IC: No-op. Too late to patch. This must be done explicitly.

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
            if apps.is_installed('rest_framework'):
                try:
                    # IC: Use absolute imports.
                    from ddtrace.contrib.django.restframework import patch_restframework
                    patch_restframework(tracer)
                except Exception:
                    log.exception('error patching rest_framework app')

            # IC: Notify that ddtrace has been configured.
            print('# Configured ddtrace.contrib.django for Django 1.6', file=sys.stderr)
