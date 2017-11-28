import decorator
import redis_lock

from ixc_django_docker.redis_lock import lock


@decorator.decorator
def enqueue_concurrent(f, *args, **kwargs):
    """
    Enqueue if task is already running.
    """
    # Get lock name.
    name = '%s:%s(*%s, **%s)' % (f.__module__, f.__name__, args, kwargs)
    with lock(name=name):
        return f(*args, **kwargs)


@decorator.decorator
def fail_concurrent(f, *args, **kwargs):
    """
    Fail if task is already running.
    """
    # Get lock name.
    name = '%s:%s(*%s, **%s)' % (f.__module__, f.__name__, args, kwargs)
    with lock(name=name, blocking=False):
        return f(*args, **kwargs)


@decorator.decorator
def skip_concurrent(f, *args, **kwargs):
    """
    Skip if task is already running.
    """
    # Get lock name.
    name = '%s:%s(*%s, **%s)' % (f.__module__, f.__name__, args, kwargs)
    try:
        with lock(name=name, blocking=False):
            return f(*args, **kwargs)
    except redis_lock.NotAcquired:
        pass
