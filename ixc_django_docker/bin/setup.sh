#!/bin/bash

# Install Node modules, Bower components and Python requirements, create a
# database, apply Django migrations, run build script, and execute a command.

set -e

mkdir -p "$PROJECT_DIR/var"

# Install Node modules.
npm-install.sh "$PROJECT_DIR"

# Install Bower components.
bower-install.sh "$PROJECT_DIR"

# Install Python requirements.
pip-install.sh "$PROJECT_DIR"

# Create a database.
setup-postgres.sh

# Apply migrations.
migrate.sh "$PROJECT_DIR/var"

# Run build script.
if [[ "$(cat package.json | jq '.scripts.build')" != null ]]; then
	echo
	echo 'Executing: npm run build...'
	echo
	npm run build
fi

# Save git commit.
FILENAME="$PROJECT_DIR/var/setup-git-commit-$(uname).txt"
echo "$(git rev-parse HEAD)" > "$FILENAME"
echo
echo "Updated '$FILENAME' ($(cat $FILENAME))"
echo

# Execute command.
exec "$@"
