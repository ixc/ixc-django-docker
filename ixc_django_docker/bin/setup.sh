#!/bin/bash

# Install Node modules, Bower components and Python requirements, create a
# database, apply Django migrations, run build script, and execute a command.

set -e

DIR="${1:-$PROJECT_DIR/var}"

mkdir -p "$DIR"

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
	echo 'Executing: npm run build...'
	npm run build
fi

# Save git commit.
echo "$(git rev-parse HEAD)" > "$DIR/setup-git-commit.txt"

# Execute command.
exec "$@"
