#!/bin/bash

# Compare git commit and wait if setup has not completed successfully.

set -e

GIT_COMMIT="$(git-commit.sh)"

# Wait for setup.
COUNT=0
while true; do
	if [[ "$GIT_COMMIT" == $(cat "$PROJECT_DIR/var/setup-git-commit.$(uname).txt" 2>&1) ]]; then
		break
	fi
	if [[ "$COUNT" == 0 ]]; then
		echo "Waiting for setup to complete for git commit: $GIT_COMMIT..."
	fi
	(( COUNT += 1 ))
	sleep 1
done
if (( COUNT > 0 )); then
	echo "Waited $COUNT seconds for setup to complete for git commit: $GIT_COMMIT"
fi

# Execute command.
exec "$@"
