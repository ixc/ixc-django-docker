#!/bin/bash

cat <<EOF
# `whoami`@`hostname`:$PWD$ nginx.sh $@
EOF

set -e

# Generate htpasswd file if credentials are set.
if [[ -n "$NGINX_BASIC_AUTH" ]]; then
	IFS=: read BASIC_AUTH_USERNAME BASIC_AUTH_PASSWORD <<< "$NGINX_BASIC_AUTH"
	echo "$BASIC_AUTH_PASSWORD" | htpasswd -ci "$IXC_DJANGO_DOCKER_DIR/etc/nginx.htpasswd" "$BASIC_AUTH_USERNAME"
fi

# Render nginx config template.
dockerize -template "$IXC_DJANGO_DOCKER_DIR/etc/nginx.tmpl.conf:$IXC_DJANGO_DOCKER_DIR/etc/nginx.conf"

exec nginx -c "$IXC_DJANGO_DOCKER_DIR/etc/nginx.conf" "$@"
