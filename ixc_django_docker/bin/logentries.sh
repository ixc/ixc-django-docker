#!/usr/bin/env bash

set -e

# Ensure HOSTNAME is set, and prefix with project and dotenv file name.
export HOSTNAME="$PROJECT_NAME-$DOTENV.${HOSTNAME:-$(hostname)}"

# Render logentries config template.
mkdir -p "$PROJECT_DIR/var/etc"
dockerize -template "${LOGENTRIES_TMPL_CONF:-$IXC_DJANGO_DOCKER_DIR/etc/logentries.tmpl.conf}:$PROJECT_DIR/var/etc/logentries.conf"

exec le monitor --config="$PROJECT_DIR/var/etc/logentries.conf"
