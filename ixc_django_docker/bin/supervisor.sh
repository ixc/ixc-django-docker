#!/usr/bin/env bash

# Start 'supervisord' or run 'supervisorctl', if arguments are given.

cat <<EOF
# `whoami`@`hostname`:$PWD$ supervisor.sh $@
EOF

set -e

if [[ -z "$@" ]]; then
	exec supervisord --configuration /opt/etc/supervisor/supervisord.conf
else
	exec supervisorctl --configuration /opt/etc/supervisor/supervisord.conf "$@"
fi
