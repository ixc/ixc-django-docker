#!/bin/bash

set -e

if [[ -z "$NEW_RELIC_LICENSE_KEY" ]]; then
	>&2 echo "'NEW_RELIC_LICENSE_KEY' is unset. Running command directly."
	exec "$@"
fi

export NEW_RELIC_APP_NAME="${NEW_RELIC_APP_NAME:-$PROJECT_NAME (${NEW_RELIC_ENVIRONMENT:-${DOTENV:-$HOSTNAME}})}"
export NEW_RELIC_CONFIG_FILE="$PROJECT_DIR/var/etc/newrelic.ini"

# Render new relic config template.
mkdir -p "$PROJECT_DIR/var/etc"
dockerize -template "${NEWRELIC_TMPL_CONF:-$IXC_DJANGO_DOCKER_DIR/etc/newrelic.tmpl.ini}:$NEW_RELIC_CONFIG_FILE"

echo "Run command via New Relic. App name: $NEW_RELIC_APP_NAME"

exec newrelic-admin run-program "$@"
