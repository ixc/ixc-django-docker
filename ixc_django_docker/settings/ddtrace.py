# See: http://pypi.datadoghq.com/trace/docs/#module-ddtrace.contrib.django

# Configure with environment variables. See 'ddtrace.sh' and
# https://github.com/DataDog/dd-trace-py/blob/master/docs/index.rst#get-started
DATADOG_TRACE = {}

INSTALLED_APPS += ('ddtrace.contrib.django', )
