# See: http://pypi.datadoghq.com/trace/docs/#module-ddtrace.contrib.django

# Configure with environment variables. See 'ddtrace.sh' and
# http://pypi.datadoghq.com/trace/docs/advanced_usage.html#ddtracerun
DATADOG_TRACE = {}

INSTALLED_APPS += ('ddtrace.contrib.django', )
