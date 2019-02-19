# See: http://pypi.datadoghq.com/trace/docs/#module-ddtrace.contrib.django

import os

# Configure with environment variables. See 'ddtrace.sh' and
# http://pypi.datadoghq.com/trace/docs/advanced_usage.html#ddtracerun
DATADOG_TRACE = {}

# Install our Django 1.6 compatible app, instead of the official one.
if os.environ.get('APM') == 'ddtrace':
    INSTALLED_APPS += ('ixc_django_docker.ddtrace16', )

    # This can't be patched before Django 1.6 iterates `MIDDLEWARE_CLASSES`,
    # so we have to add it explicitly.
    MIDDLEWARE_CLASSES = \
        ('ddtrace.contrib.django.TraceMiddleware', ) + \
        MIDDLEWARE_CLASSES + \
        ('ddtrace.contrib.django.TraceExceptionMiddleware', )
