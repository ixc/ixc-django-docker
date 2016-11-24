#!/bin/bash

cat <<EOF
# `whoami`@`hostname`:$PWD$ celerybeat.sh $@
EOF

set -e

exec celery --app=ixc_django_docker beat --loglevel=INFO -S djcelery.schedulers.DatabaseScheduler --pidfile= "$@"
