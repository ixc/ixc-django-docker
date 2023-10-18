from __future__ import absolute_import

import datetime
import logging

from django.core.cache.backends import dummy
import decorator
import redis
import redis_lock

from ixc_django_docker import appsettings

logger = logging.getLogger(__name__)


class DummyCache(dummy.DummyCache):
    """
    Maintain API compatibility with ``redis_lock.django_cache.RedisCache``,
    which adds a convenient ``lock()`` method.
    """

    def lock(self, *args, **kwargs):
        yield


@decorator.contextmanager
def lock(
        name,
        expire=60,
        auto_renewal=True,
        blocking=True,
        host=appsettings.REDIS_HOST,
        port=appsettings.REDIS_PORT,
        protocol=appsettings.REDIS_PROTOCOL):

    conn = redis.StrictRedis(
        host=host,
        port=port,
        ssl=protocol == "rediss",
    )

    # Create lock object.
    lock = redis_lock.Lock(
        conn, name=name, expire=expire, auto_renewal=auto_renewal)

    # Attempt to acquire lock.
    if lock.acquire(blocking=False):
        logger.debug('Acquired lock: %s' % name)

    # Block until lock is available, then execute.
    elif blocking:
        logger.info('Waiting to acquire lock: %s' % name)
        when = datetime.datetime.now()
        lock.acquire()
        duration = datetime.datetime.now() - when
        logger.info(
            'Waited %s seconds to acquire lock: %s' % (
                duration.seconds,
                name,
            ))

    # Raise an exception when a non-blocking lock cannot be acquired.
    else:
        raise redis_lock.NotAcquired('Unable to acquire lock.')

    try:
        yield
    finally:
        # Always release the lock.
        try:
            lock.release()
        except redis_lock.NotAcquired:
            pass
