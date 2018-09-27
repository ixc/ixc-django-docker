#!/bin/bash

# Compare git commit and wait if setup has not completed successfully.

set -e

# Wait for setup.
COUNT=0
while true; do
	GIT_COMMIT="$(git rev-parse HEAD)"
	if [[ "$GIT_COMMIT" == $(cat "$DIR/setup-git-commit.txt" 2>&1) ]]; then
		break
	fi
	if [[ "$COUNT" == 0 ]]; then
		echo "Waiting for setup to complete for git commit: '$GIT_COMMIT'..."
	fi
	(( COUNT += 1 ))
	sleep 1
done
if (( COUNT > 0 )); then
	echo "Waited $COUNT seconds for setup to complete."
fi

# Execute command.
exec "$@"
