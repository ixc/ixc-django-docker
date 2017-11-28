from django.conf import settings

REDIS_ADDRESS = getattr(settings, 'REDIS_ADDRESS', 'localhost:6379')
REDIS_HOST, REDIS_PORT = REDIS_ADDRESS.split(':')
