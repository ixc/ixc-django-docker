#!/bin/bash

# Compare git commit and wait if setup has not completed successfully.

cat <<EOF
# `whoami`@`hostname`:$PWD$ setup-wait.sh $@
EOF

set -e

# Wait for Redis.
dockerize -timeout 1m -wait "tcp://${REDIS_ADDRESS:-setup:8000}"

# Wait for setup.
COUNT=0
GIT_COMMIT="$(git rev-parse HEAD)"
until redis-cache.py -q match ixc-django-docker:setup-git-commit "$GIT_COMMIT" 2>&1; do
	if [[ "$COUNT" == 0 ]]; then
		echo "Waiting for setup to complete for '$GIT_COMMIT'..."
	fi
	(( COUNT += 1 ))
	sleep 1
done
if (( COUNT > 0 )); then
	echo "Waited $COUNT seconds for setup to complete."
fi

# Execute command.
exec "$@"
