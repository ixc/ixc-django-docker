#!/bin/bash

# Install Node modules, Bower components and Python requirements, create a
# database, apply Django migrations, run build script, and execute a command.

set -e

if [[ -z "$PROJECT_DIR" ]]; then
	>&2 echo "ERROR: Missing environment variable: PROJECT_DIR"
	exit 1
fi

mkdir -p "$DIR/var"

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
echo 'Executing: npm run build...'
npm run build --if-present

# Save git commit.
echo "$(git rev-parse HEAD)" > "$PROJECT_DIR/var/setup-git-commit.txt"
echo "Updated '$PROJECT_DIR/var/setup-git-commit.txt' ($(cat $PROJECT_DIR/var/setup-git-commit.txt))"

# Execute command.
exec "$@"
