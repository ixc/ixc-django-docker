#!/bin/bash

cat <<EOF
# `whoami`@`hostname`:$PWD$ gunicorn.sh $@
EOF

set -e

# See: http://docs.gunicorn.org/en/stable/design.html#how-many-workers
let "GUNICORN_WORKERS = ${GUNICORN_WORKERS:-${CPU_CORES:-1} * 2 + 1}"

exec gunicorn --bind 0.0.0.0:8080 --timeout "${GUNICORN_TIMEOUT:-60}" --workers "$GUNICORN_WORKERS" "${@:-ixc_django_docker.wsgi:application}"
