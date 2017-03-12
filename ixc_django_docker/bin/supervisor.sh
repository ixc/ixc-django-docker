#!/usr/bin/env bash

# Start 'supervisord' or run 'supervisorctl', if arguments are given.

cat <<EOF
# `whoami`@`hostname`:$PWD$ supervisor.sh $@
EOF

set -e

# Render project or default programs config template.
if [[ -f "$PROJECT_DIR/etc/supervisord.tmpl.conf" ]]; then
	dockerize -template "$PROJECT_DIR/etc/supervisord.tmpl.conf:$PROJECT_DIR/etc/supervisord.conf"
	export SUPERVISORD_INCLUDE="$PROJECT_DIR/etc/supervisord.conf"
else
	dockerize -template "$IXC_DJANGO_DOCKER_DIR/etc/supervisord.nginx-proxy.tmpl.conf:$IXC_DJANGO_DOCKER_DIR/etc/supervisord.nginx-proxy.conf"
	export SUPERVISORD_INCLUDE="supervisord.nginx-proxy.conf"
fi

# Render supervisord config template.
dockerize -template "$IXC_DJANGO_DOCKER_DIR/etc/supervisord.tmpl.conf:$IXC_DJANGO_DOCKER_DIR/etc/supervisord.conf"

if [[ -z "$@" ]]; then
	exec supervisord --configuration "$IXC_DJANGO_DOCKER_DIR/etc/supervisord.conf"
else
	exec supervisorctl --configuration "$IXC_DJANGO_DOCKER_DIR/etc/supervisord.conf" "$@"
fi
