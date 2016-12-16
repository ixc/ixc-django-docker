#!/bin/bash

cat <<EOF
# `whoami`@`hostname`:$PWD$ celery.sh $@
EOF

set -e

# Allow Celery to run as root.
export C_FORCE_ROOT=1

exec celery --app="${CELERY_APP:-ixc_django_docker.celery}" worker --loglevel=INFO "$@"
