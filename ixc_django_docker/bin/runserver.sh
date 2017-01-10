#!/bin/bash

cat <<EOF
# `whoami`@`hostname`:$PWD$ runserver.sh $@
EOF

set -e

if [[ -n "${DOCKER_FOR_MAC+1}" ]]; then
	cat <<-EOF
	Disable auto-reload under Docker for Mac to avoid high CPU utilisation.
	See: https://docs.docker.com/docker-for-mac/osxfs/#/performance-issues-solutions-and-roadmap
	EOF
	set -- --noreload "$@"
fi

exec manage.py runserver "$@" 0.0.0.0:8000
