#!/bin/bash

# Install Node modules, Bower components and Python requirements, create a
# database, apply Django migrations, run build script, and execute a command.

set -e

if [[ -z "$PROJECT_DIR" ]]; then
	>&2 echo "ERROR: Missing environment variable: PROJECT_DIR"
	exit 1
fi

mkdir -p "$PROJECT_DIR/var"

UNAME="$(uname)"

if [[ -n "${SETUP_FORCE+1}" ]]; then
	>&2 echo "SETUP_FORCE is set. Delete '*.md5.$UNAME' files."
	find . -name "*.md5.$UNAME" -delete
	rm -f "$PROJECT_DIR/var/migrate.txt.$UNAME"
fi

# Install Node modules.
npm-install.sh "$PROJECT_DIR"

# Install Bower components.
bower-install.sh "$PROJECT_DIR"

# Install Python requirements.
pip-install.sh "$PROJECT_DIR"

# Create a database.
setup-postgres.sh

# Execute setup command.
if [[ -n "${SETUP_COMMAND+1}" ]]; then
	echo "Executing setup command: ${SETUP_COMMAND}"
	bash -c "${SETUP_COMMAND}"
fi

# Apply migrations last. Because the database is shared state and there might be
# backwards incompatible changes. This should reduce the duration of any potential
# downtime before recreating old containers, caused by a slow `SETUP_COMMAND` (above).
migrate.sh "$PROJECT_DIR/var"

# Save git commit.
echo "$(git-commit.sh)" > "$PROJECT_DIR/var/setup-git-commit.txt.$UNAME"
echo "Updated '$PROJECT_DIR/var/setup-git-commit.txt.$UNAME' ($(cat $PROJECT_DIR/var/setup-git-commit.txt.$UNAME))"

# Execute command.
exec "$@"
