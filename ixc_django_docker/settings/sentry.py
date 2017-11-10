INSTALLED_APPS += ('raven.contrib.django.raven_compat', )
RAVEN_CONFIG = {'dsn': os.environ.get('SENTRY_DSN'), }
