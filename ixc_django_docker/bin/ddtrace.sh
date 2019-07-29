#!/bin/bash

set -e

export DATADOG_ENV="${DATADOG_ENV:-$PROJECT_NAME-${DATADOG_ENV:-$DOTENV}}"
export DD_TRACE_ANALYTICS_ENABLED='true'

# For ddtrace < 0.25.
export DD_ANALYTICS_ENABLED="$DD_TRACE_ANALYTICS_ENABLED"

echo 'Run command via Datadog Trace Client.'

exec ddtrace-run "$@"
