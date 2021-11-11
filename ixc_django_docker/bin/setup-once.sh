#!/bin/bash

# Compare git commit and run setup one time only.

set -e

GIT_COMMIT="$(git-commit.sh)"

if [[ "$GIT_COMMIT" == $(cat "$PROJECT_DIR/var/setup-git-commit.txt.$(uname)" 2>&1) ]]; then
    echo "Setup already complete for git commit: $GIT_COMMIT"
    exit 0
fi

exec setup.sh "$@"
