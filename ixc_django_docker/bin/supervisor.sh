#!/usr/bin/env bash

# Start 'supervisord' or run 'supervisorctl', if arguments are given.

set -e

# Create context specific config and run directories.
if [[ -z "${CONTEXT+1}" ]]; then
	ETC_DIR="$PROJECT_DIR/var/etc"
	export RUN_DIR="$PROJECT_DIR/var/run"
else
	ETC_DIR="$PROJECT_DIR/var/etc/$CONTEXT"
	export RUN_DIR="$PROJECT_DIR/var/run/$CONTEXT"
fi
mkdir -p "$ETC_DIR" "$RUN_DIR"

# Get a random-ish port in the 59000-59999 range.
# See: https://github.com/rfk/django-supervisor/blob/be2013c4826ae49730664b359ee285fa03b16c09/djsupervisor/config.py#L107-L111
export SUPERVISOR_PORT="${SUPERVISOR_PORT:-59$(python.sh -c "import hashlib; print('%03d' % (int(hashlib.md5(u'$ETC_DIR'.encode('utf-8')).hexdigest()[:3], 16) % 1000));")}"

# Default environment variables for config template.
export NGINX_PROXY_PORT="${NGINX_PROXY_PORT:-8080}"
export SUPERVISOR_PROGRAM="${SUPERVISOR_PROGRAM:-gunicorn}"
export SUPERVISOR_PROGRAM_ENVIRONMENT="${SUPERVISOR_PROGRAM_ENVIRONMENT:-}"
export SUPERVISOR_PROGRAM_NUMPROCS="${SUPERVISOR_PROGRAM_NUMPROCS:-1}"
export SUPERVISOR_STOPSIGNAL="${SUPERVISOR_STOPSIGNAL:-TERM}"

# Render config templates.
dockerize -template "${SUPERVISOR_TMPL_CONF:-$IXC_DJANGO_DOCKER_DIR/etc/supervisord.tmpl.conf}:$ETC_DIR/supervisord.conf"
dockerize -template "${SUPERVISOR_INCLUDE_TMPL_CONF:-$IXC_DJANGO_DOCKER_DIR/etc/supervisord.include.tmpl.conf}:$ETC_DIR/supervisord.include.conf"

if [[ -z "$@" ]]; then
	exec supervisord --configuration "$ETC_DIR/supervisord.conf"
else
	exec supervisorctl --configuration "$ETC_DIR/supervisord.conf" --serverurl "http://localhost:$SUPERVISOR_PORT" "$@"
fi
