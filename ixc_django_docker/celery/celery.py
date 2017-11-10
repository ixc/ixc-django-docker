# CELERY ######################################################################

# See: http://docs.celeryproject.org/en/3.1/django/first-steps-with-django.html

from __future__ import absolute_import

import os

from celery import Celery

# set the default Django settings module for the 'celery' program.
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'ixc_django_docker.settings')

from django.conf import settings  # noqa

app = Celery('ixc-django-docker')

# Using a string here means the worker will not have to
# pickle the object when using Windows.
app.config_from_object('django.conf:settings')
app.autodiscover_tasks(lambda: settings.INSTALLED_APPS)


@app.task(bind=True)
def debug_task(self):
    print('Request: {0!r}'.format(self.request))

# SENTRY ######################################################################

# See: https://docs.sentry.io/clients/python/integrations/celery/

if getattr(settings, 'RAVEN_CONFIG', {}).get('dsn'):

    from raven import Client
    from raven.contrib.celery import register_signal, register_logger_signal

    client = Client(settings.RAVEN_CONFIG.get('dsn'))

    # register a custom filter to filter out duplicate logs
    register_logger_signal(client)

    # hook into the Celery error handler
    register_signal(client)
