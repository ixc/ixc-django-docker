#!/bin/bash

cat <<EOF
# `whoami`@`hostname`:$PWD$ nginx.sh $@
EOF

set -e

exec nginx -c "$IXC_DJANGO_DOCKER_DIR/etc/nginx.conf" "$@"
