# Use a real cache backend.
CACHES['default'].update({
    'BACKEND': 'redis_lock.django_cache.RedisCache',
    'LOCATION': 'redis://%s/0' % REDIS_ADDRESS,
})
