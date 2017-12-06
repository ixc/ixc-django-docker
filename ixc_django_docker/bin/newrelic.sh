#!/bin/bash

cat <<EOF
# `whoami`@`hostname`:$PWD$ newrelic.sh $@
EOF

set -e

if [[ -z "$NEW_RELIC_LICENSE_KEY" ]]; then
	>&2 echo "'NEW_RELIC_LICENSE_KEY' is unset. Executing command directly."
	exec "$@"
fi

export NEW_RELIC_APP_NAME="${NEW_RELIC_APP_NAME:-$PROJECT_NAME (${NEW_RELIC_ENVIRONMENT:-${DOTENV:-$HOSTNAME}})}"
export NEW_RELIC_CONFIG_FILE="$IXC_DJANGO_DOCKER_DIR/etc/newrelic.ini"

# Render new relic config template.
dockerize -template "$IXC_DJANGO_DOCKER_DIR/etc/newrelic.tmpl.ini:$NEW_RELIC_CONFIG_FILE"

exec newrelic-admin run-program "$@"
