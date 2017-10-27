from django.core.cache.backends import dummy


class DummyCache(dummy.DummyCache):
    """
    Maintain API compatibility with ``redis_lock.django_cache.RedisCache``,
    which adds a convenient ``lock()`` method.
    """

    def lock(self, *args, **kwargs):
        yield
