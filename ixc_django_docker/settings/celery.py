from kombu import Exchange, Queue

BROKER_URL = 'redis://%s/0' % REDIS_ADDRESS
CELERY_ACCEPT_CONTENT = ['json', 'msgpack', 'yaml']  # 'pickle'
CELERY_DEFAULT_QUEUE = PROJECT_SLUG

CELERY_QUEUES = (
    Queue(
        CELERY_DEFAULT_QUEUE,
        Exchange(CELERY_DEFAULT_QUEUE),
        routing_key=CELERY_DEFAULT_QUEUE
    ),
)

CELERY_RESULT_BACKEND = 'djcelery.backends.database:DatabaseBackend'
CELERY_TASK_SERIALIZER = 'json'
CELERY_TIMEZONE = TIME_ZONE
CELERYBEAT_SCHEDULE = {}
CELERYD_MAX_TASKS_PER_CHILD = 20

INSTALLED_APPS += (
    'djcelery',
    'ixc_django_docker.celery',
    'kombu.transport.django',
)
