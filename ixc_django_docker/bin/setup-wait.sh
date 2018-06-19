#!/bin/bash

# Compare git commit and wait if setup has not completed successfully.

cat <<EOF
# `whoami`@`hostname`:$PWD$ setup-wait.sh $@
EOF

set -e

# Wait for Redis.
dockerize -timeout 1m -wait "tcp://${REDIS_ADDRESS:-setup:8000}"

# Wait for setup.
GIT_COMMIT="$(git rev-parse HEAD)"
while ! redis-cache.py -q match ixc-django-docker:setup-git-commit "$GIT_COMMIT"; do
	>&2 echo "Setup is not complete for git commit '$GIT_COMMIT'. Sleeping for 1 second."
	sleep 1
done

# Execute command.
exec "$@"
