#!/usr/bin/env bash

# Start 'supervisord' or run 'supervisorctl', if arguments are given.

cat <<EOF
# `whoami`@`hostname`:$PWD$ supervisor.sh $@
EOF

set -e

export SUPERVISORD_INCLUDE="${SUPERVISORD_INCLUDE:-supervisord.default.conf}"

if [[ -z "$@" ]]; then
	exec supervisord --configuration "$IXC_DJANGO_DOCKER_DIR/etc/supervisord.conf"
else
	exec supervisorctl --configuration "$IXC_DJANGO_DOCKER_DIR/etc/supervisord.conf" "$@"
fi
