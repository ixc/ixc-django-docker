from __future__ import absolute_import

from celery.schedules import crontab
import celery

BROKER_URL = 'redis://%s/0' % REDIS_ADDRESS
CELERY_ACCEPT_CONTENT = ['json', 'msgpack', 'yaml']  # 'pickle'
CELERY_DEFAULT_QUEUE = PROJECT_SLUG
CELERY_TASK_SERIALIZER = 'json'
CELERY_TIMEZONE = TIME_ZONE
CELERYBEAT_SCHEDULE_FILENAME = os.path.join(VAR_DIR, 'run/celerybeat-schedule')

CELERYBEAT_SCHEDULE = {
    'clearsessions': {
        'task': 'ixc_django_docker.celery.tasks.call_command',
        'schedule': crontab(hour=10, minute=0, day_of_week=3),
        'args': ('clearsessions', ),
    },
}

CELERYD_MAX_TASKS_PER_CHILD = 50

INSTALLED_APPS += (
    'ixc_django_docker.celery',
)

if celery.__version__ >= '4.0':
    CELERY_RESULT_BACKEND = 'django-db'
    INSTALLED_APPS += ('django_celery_results', )
else:
    CELERY_RESULT_BACKEND = 'djcelery.backends.database:DatabaseBackend'
    INSTALLED_APPS += ('djcelery', )
