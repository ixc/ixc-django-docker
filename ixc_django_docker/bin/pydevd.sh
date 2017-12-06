#!/usr/bin/env bash

cat <<EOF
# `whoami`@`hostname`:$PWD$ pydevd.sh $@
EOF

set -e

export PYDEVD=1

exec "$@"
