import os
import multiprocessing
import six


def truthy(val):
    return six.text_type(val) in ('1', 'on', 't', 'true', 'y', 'yes')


accesslog = os.environ.get('GUNICORN_ACCESS_LOG') or None
bind = '0.0.0.0:%s' % os.environ.get('NGINX_PROXY_PORT', 8080)
limit_request_line = os.environ.get('GUNICORN_LIMIT_REQUEST_LINE', 4094)  # Default
max_requests = os.environ.get('GUNICORN_MAX_REQUESTS', 10000)
max_requests_jitter = os.environ.get('GUNICORN_MAX_REQUESTS_JITTER', 1000)
preload_app = truthy(os.environ.get('GUNICORN_PRELOAD', 'true'))
threads = os.environ.get('GUNICORN_THREADS', 1)
timeout = os.environ.get('GUNICORN_TIMEOUT', 50)  # HAproxy default
worker_class = os.environ.get('GUNICORN_WORKER_CLASS', 'sync')
workers = os.environ.get('GUNICORN_WORKERS', 1)

if workers == 'auto':
    if worker_class == 'sync':
        # See: http://docs.gunicorn.org/en/stable/design.html#how-many-workers
        workers = multiprocessing.cpu_count() * 2 + 1
    else:
        # One worker per CPU core for async workers.
        workers = multiprocessing.cpu_count()
