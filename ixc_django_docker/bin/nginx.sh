#!/bin/bash

cat <<EOF
# `whoami`@`hostname`:$PWD$ nginx.sh $@
EOF

set -e

# Generate htpasswd file if credentials are set.
if [[ -n "$NGINX_BASIC_AUTH" ]]; then
	# Split on `:`.
	IFS=: read BASIC_AUTH_USERNAME BASIC_AUTH_PASSWORD <<< "$NGINX_BASIC_AUTH"
	echo "$BASIC_AUTH_PASSWORD" | htpasswd -ci "$PROJECT_DIR/var/etc/nginx.htpasswd" "$BASIC_AUTH_USERNAME"
fi

export NGINX_WORKER_PROCESSES="${NGINX_WORKER_PROCESSES:-auto}"

# Render nginx config template.
mkdir -p "$PROJECT_DIR/var/etc"
dockerize -template "${NGINX_TMPL_CONF:-$IXC_DJANGO_DOCKER_DIR/etc/nginx.tmpl.conf}:$PROJECT_DIR/var/etc/nginx.conf"

# Set `error_log` via command line to avoid a permissions error when run as an
# unprivileged user. See: https://stackoverflow.com/a/24423319
exec nginx -c "$PROJECT_DIR/var/etc/nginx.conf" -g "error_log /dev/stderr;" "$@"
