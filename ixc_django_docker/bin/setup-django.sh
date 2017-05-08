#!/bin/bash

# Install Node modules, Bower components and Python requirements, create a
# database, apply Django migrations, and execute a command.

cat <<EOF
# `whoami`@`hostname`:$PWD$ setup-django.sh $@
EOF

set -e

cat <<EOF
#
# Do not be alarmed if you see "Waiting to acquire lock for command:" for
# several minutes at a time. It might seem like nothing is happening, but the
# command is already running in another background container.
#
# You can see the logs for all containers with:
#
#     $ docker-compose logs -f
#
EOF

# Install Node modules.
waitlock.py -b npm-install.sh "$PROJECT_DIR"

# Install Bower components.
waitlock.py -b bower-install.sh "$PROJECT_DIR"

# Install Python requirements.
waitlock.py -b pip-install.sh "$PROJECT_DIR"

# Create a database.
waitlock.py -b setup-postgres.sh

# Apply migrations.
waitlock.py -b migrate.sh "$PROJECT_DIR/var"

# Execute command.
exec "$@"
