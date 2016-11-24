#!/bin/bash

cat <<EOF
# `whoami`@`hostname`:$PWD$ runserver.sh $@
EOF

set -e

exec manage.py runserver "${@:-0.0.0.0:8000}"
