#!/bin/bash

cat <<EOF
# `whoami`@`hostname`:$PWD$ ddtrace.sh $@
EOF

set -e

export DATADOG_ENV="${DATADOG_ENV:-$PROJECT_NAME-${DATADOG_ENV:-$DOTENV}}"

echo 'Run command via Datadog Trace Client.'

exec ddtrace-run "$@"
