from __future__ import absolute_import

from .celery import app
from django.core import management
import decorator
import redis_lock

from ixc_django_docker.redis_lock import lock


@decorator.decorator
def enqueue_concurrent(f, lock_kwargs=None, *args, **kwargs):
    """
    Enqueue if task is already running.
    """
    lock_kwargs = lock_kwargs or {}
    # Get lock name.
    name = '%s:%s(*%s, **%s)' % (f.__module__, f.__name__, args, kwargs)
    with lock(name=name, **lock_kwargs):
        return f(*args, **kwargs)


@decorator.decorator
def fail_concurrent(f, lock_kwargs=None, *args, **kwargs):
    """
    Fail if task is already running.
    """
    lock_kwargs = lock_kwargs or {}
    lock_kwargs.setdefault('blocking', False)
    # Get lock name.
    name = '%s:%s(*%s, **%s)' % (f.__module__, f.__name__, args, kwargs)
    with lock(name=name, **lock_kwargs):
        return f(*args, **kwargs)


@decorator.decorator
def skip_concurrent(f, lock_kwargs=None, *args, **kwargs):
    """
    Skip if task is already running.
    """
    lock_kwargs = lock_kwargs or {}
    lock_kwargs.setdefault('blocking', False)
    # Get lock name.
    name = '%s:%s(*%s, **%s)' % (f.__module__, f.__name__, args, kwargs)
    try:
        with lock(name=name, **lock_kwargs):
            return f(*args, **kwargs)
    except redis_lock.NotAcquired:
        return 'Skipped. Unable to acquire lock: %s' % name


@app.task
@skip_concurrent
def call_command(*args, **kwargs):
    return management.call_command(*args, **kwargs)
