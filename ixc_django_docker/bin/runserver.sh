#!/bin/bash

set -e

export NGINX_PROXY_PORT="${NGINX_PROXY_PORT:-8000}"

exec gunicorn.sh --access-logformat '%(t)s "%(r)s" %(s)s %(b)s' --reload --workers 1 "${@:-ixc_django_docker.wsgi:application}"
