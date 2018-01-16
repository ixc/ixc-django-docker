#!/usr/bin/env bash

# Start 'supervisord' or run 'supervisorctl', if arguments are given.

cat <<EOF
# `whoami`@`hostname`:$PWD$ supervisor.sh $@
EOF

set -e

# Render config templates.
dockerize -template "${SUPERVISORD_TMPL_CONF:-$IXC_DJANGO_DOCKER_DIR/etc/supervisord.tmpl.conf}:$PROJECT_DIR/var/etc/supervisord.conf"
dockerize -template "${SUPERVISORD_INCLUDE_TMPL_CONF:-$IXC_DJANGO_DOCKER_DIR/etc/supervisord.nginx-proxy.tmpl.conf}:$PROJECT_DIR/var/etc/supervisord.include.conf"

if [[ -z "$@" ]]; then
	exec supervisord --configuration "$PROJECT_DIR/var/etc/supervisord.conf"
else
	exec supervisorctl --configuration "$PROJECT_DIR/var/etc/supervisord.conf" "$@"
fi
