#!/bin/bash

set -e

export NGINX_PROXY_PORT="${NGINX_PROXY_PORT:-8000}"
export GUNICORN_WORKERS=1

exec gunicorn.sh --access-logformat '%(t)s "%(r)s" %(s)s %(b)s' --reload "$@"
