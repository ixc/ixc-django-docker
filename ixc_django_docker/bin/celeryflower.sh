#!/bin/bash

cat <<EOF
# `whoami`@`hostname`:$PWD$ celeryflower.sh $@
EOF

set -e

exec newrelic.sh celery --app="${CELERY_APP:-ixc_django_docker.celery}" flower --port=8080 "$@"
