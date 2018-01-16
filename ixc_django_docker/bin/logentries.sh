#!/usr/bin/env bash

set -e

# Render logentries config template.
dockerize -template "${LOGENTRIES_TMPL_CONF:-$IXC_DJANGO_DOCKER_DIR/etc/logentries.tmpl.conf}:$PROJECT_DIR/var/etc/logentries.conf"

exec le monitor --config="$PROJECT_DIR/var/etc/logentries.conf"
