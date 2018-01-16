#!/usr/bin/env bash

# Start 'supervisord' or run 'supervisorctl', if arguments are given.

cat <<EOF
# `whoami`@`hostname`:$PWD$ supervisor.sh $@
EOF

set -e

# Get a random-ish port in the 59000-59999 range. See: https://github.com/rfk/django-supervisor/blob/be2013c4826ae49730664b359ee285fa03b16c09/djsupervisor/config.py#L107-L111
export SUPERVISORD_PORT="${SUPERVISORD_PORT:-59$(python -c "import hashlib; print('%03d' % (int(hashlib.md5('$PROJECT_DIR').hexdigest()[:3], 16) % 1000));")}"

# Render config templates.
dockerize -template "${SUPERVISORD_TMPL_CONF:-$IXC_DJANGO_DOCKER_DIR/etc/supervisord.tmpl.conf}:$PROJECT_DIR/var/etc/supervisord.conf"
dockerize -template "${SUPERVISORD_INCLUDE_TMPL_CONF:-$IXC_DJANGO_DOCKER_DIR/etc/supervisord.include.tmpl.conf}:$PROJECT_DIR/var/etc/supervisord.include.conf"

if [[ -z "$@" ]]; then
	exec supervisord --configuration "$PROJECT_DIR/var/etc/supervisord.conf"
else
	exec supervisorctl --configuration "$PROJECT_DIR/var/etc/supervisord.conf" --serverurl "http://localhost:$SUPERVISORD_PORT" "$@"
fi
