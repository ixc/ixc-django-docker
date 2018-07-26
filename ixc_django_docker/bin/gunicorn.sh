#!/bin/bash

cat <<EOF
# `whoami`@`hostname`:$PWD$ gunicorn.sh $@
EOF

set -e

exec "${APM:-newrelic}.sh" gunicorn --config "$IXC_DJANGO_DOCKER_DIR/etc/gunicorn.py" $GUNICORN_OPTIONS "${@:-ixc_django_docker.wsgi:application}"
