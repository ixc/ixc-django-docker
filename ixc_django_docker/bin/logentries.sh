#!/usr/bin/env bash

set -e

# Render logentries config template.
dockerize -template "$IXC_DJANGO_DOCKER_DIR/etc/logentries.tmpl.conf:$IXC_DJANGO_DOCKER_DIR/etc/logentries.conf"

exec le monitor --config="$IXC_DJANGO_DOCKER_DIR/etc/logentries.conf"
