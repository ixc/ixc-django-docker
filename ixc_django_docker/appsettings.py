from django.conf import settings

ENABLE_S3_STORAGE = getattr(settings, 'ENABLE_S3_STORAGE', False)
ENABLE_UNIQUE_STORAGE = getattr(settings, 'ENABLE_UNIQUE_STORAGE', True)

REDIS_ADDRESS = getattr(settings, 'REDIS_ADDRESS', 'localhost:6379')
REDIS_HOST, REDIS_PORT = REDIS_ADDRESS.split(':')
REDIS_PROTOCOL = getattr(settings, 'REDIS_PROTOCOL', 'redis')
