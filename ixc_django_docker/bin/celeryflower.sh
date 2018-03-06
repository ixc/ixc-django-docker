#!/bin/bash

cat <<EOF
# `whoami`@`hostname`:$PWD$ celeryflower.sh $@
EOF

set -e

# Set new config defaults.
export FLOWER_DB="${FLOWER_DB:-$PROJECT_DIR/var/flower}"
export FLOWER_PERSISTENT="${FLOWER_PERSISTENT:-True}"
export FLOWER_PORT="${FLOWER_PORT:-${NGINX_PROXY_PORT:-8080}}"
export FLOWER_TASKS_COLUMNS="${FLOWER_TASKS_COLUMNS:-name,uuid,state,args,kwargs,result,received,started,runtime,worker,retries,revoked,exception,expires,eta}"

exec newrelic.sh celery --app="${CELERY_APP:-ixc_django_docker.celery}" flower "$@"
