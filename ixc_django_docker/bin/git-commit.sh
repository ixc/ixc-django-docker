#!/bin/bash

# Print the current git commit or '$GIT_COMMIT'.

set -e

if [[ -d .git ]]; then
	echo "$(git rev-parse HEAD)"
else
	echo "${GIT_COMMIT}"
fi
