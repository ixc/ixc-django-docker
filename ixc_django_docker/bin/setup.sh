#!/bin/bash

# Install Node modules, Bower components and Python requirements, create a
# database, apply Django migrations, run build script, and execute a command.

set -e

if [[ -z "$PROJECT_DIR" ]]; then
	>&2 echo "ERROR: Missing environment variable: PROJECT_DIR"
	exit 1
fi

mkdir -p "$PROJECT_DIR/var"

if [[ -n "${SETUP_FORCE+1}" ]]; then
	>&2 echo 'SETUP_FORCE is set. Delete "*.md5" files.'
	find . -name "*.md5" -delete
fi

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

# Run 'setup' script.
echo "Executing: npm run ${SETUP_NPM_RUN:-setup}..."
npm run "${SETUP_NPM_RUN:-setup}" --if-present

# Save git commit.
echo "$(git-commit.sh)" > "$PROJECT_DIR/var/setup-git-commit.txt"
echo "Updated '$PROJECT_DIR/var/setup-git-commit.txt' ($(cat $PROJECT_DIR/var/setup-git-commit.txt))"

# Execute command.
exec "$@"
