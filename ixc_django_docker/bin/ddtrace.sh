#!/bin/bash

set -e

export DD_ENV="${DATADOG_ENV:-$PROJECT_NAME-${DATADOG_ENV:-$DOTENV}}"
export DD_TRACE_ANALYTICS_ENABLED='true'

# Legacy.
export DATADOG_ENV="${DD_ENV}"
export DD_ANALYTICS_ENABLED="${DD_TRACE_ANALYTICS_ENABLED}"

echo 'Run command via Datadog Trace Client.'

exec ddtrace-run "$@"
