# See: http://pypi.datadoghq.com/trace/docs/#module-ddtrace.contrib.django

# Configure with environment variables. See 'ddtrace.sh' and
# http://pypi.datadoghq.com/trace/docs/advanced_usage.html#ddtracerun
DATADOG_TRACE = {}

# Install our Django 1.6 compatible app, instead of the official one.
INSTALLED_APPS += ('ixc_django_docker.ddtrace', )
