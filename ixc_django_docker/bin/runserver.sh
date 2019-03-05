#!/bin/bash

set -e

export NGINX_PROXY_PORT="${NGINX_PROXY_PORT:-8000}"
export GUNICORN_PRELOAD='false'
export GUNICORN_THREADS="${GUNICORN_THREADS:-3}"
export GUNICORN_WORKERS="${GUNICORN_WORKERS:-1}"

exec gunicorn.sh --access-logformat '%(t)s "%(r)s" %(s)s %(b)s' --reload "${@:-ixc_django_docker.wsgi:application}"
