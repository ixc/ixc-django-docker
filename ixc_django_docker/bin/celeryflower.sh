#!/bin/bash

cat <<EOF
# `whoami`@`hostname`:$PWD$ celeryflower.sh $@
EOF

set -e

exec celery --app=ixc_django_docker flower "$@"
