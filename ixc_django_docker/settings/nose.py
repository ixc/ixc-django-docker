import sys

INSTALLED_APPS += ('django_nose', )

NOSE_ARGS = (
    '--logging-clear-handlers',  # Clear all other logging handlers
    '--nocapture',  # Don't capture stdout
    '--nologcapture',  # Disable logging capture plugin
    # '--processes=-1',  # Automatically set to the number of cores
)

# Temporarily disabled until nose-progressive adds support for setuptools>=58
#if sys.stdout.isatty():
#    NOSE_ARGS += ('--with-progressive', )  # See https://github.com/erikrose/nose-progressive

TEST_RUNNER = 'django_nose.NoseTestSuiteRunner'  # Default: django.test.runner.DiscoverRunner
