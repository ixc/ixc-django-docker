import os
import multiprocessing

accesslog = os.environ.get('GUNICORN_ACCESS_LOG', '-') or None
bind = '0.0.0.0:%s' % os.environ.get('NGINX_PROXY_PORT', 8080)
threads = os.environ.get('GUNICORN_THREADS', 1)
timeout = os.environ.get('GUNICORN_TIMEOUT', 50)  # HAproxy default
worker_class = os.environ.get('GUNICORN_WORKER_CLASS', 'sync')
workers = os.environ.get('GUNICORN_WORKERS')

if not workers:
    if worker_class == 'sync':
        # See: http://docs.gunicorn.org/en/stable/design.html#how-many-workers
        workers = multiprocessing.cpu_count() * 2 + 1
    else:
        # One worker per CPU core for async workers.
        workers = multiprocessing.cpu_count()
