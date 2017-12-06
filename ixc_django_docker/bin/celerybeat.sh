#!/bin/bash

cat <<EOF
# `whoami`@`hostname`:$PWD$ celerybeat.sh $@
EOF

set -e

exec newrelic.sh celery --app="${CELERY_APP:-ixc_django_docker.celery}" beat --loglevel=INFO -S djcelery.schedulers.DatabaseScheduler --pidfile= "$@"
