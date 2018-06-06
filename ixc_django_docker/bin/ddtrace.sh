#!/bin/bash

cat <<EOF
# `whoami`@`hostname`:$PWD$ ddtrace.sh $@
EOF

set -e

export DATADOG_ENV="${DATADOG_ENV:-$DOTENV}"
export DATADOG_SERVICE_NAME="${DATADOG_SERVICE_NAME:-$PROJECT_NAME}"

echo 'Run command via Datadog Trace Client.'

exec ddtrace-run "$@"
