#!/bin/bash

# Install Node modules, Bower components and Python requirements, create a
# database, apply Django migrations, clear caches, and execute a command.

cat <<EOF
# `whoami`@`hostname`:$PWD$ setup.sh $@
EOF

set -e

# Wait for Redis.
dockerize -timeout 1m -wait "tcp://$REDIS_ADDRESS"

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

# Clear caches.
clear-cache.sh

# Cache git commit.
redis-cache.py -vv set ixc-django-docker:setup-git-commit "$(git rev-parse HEAD)"

# Execute command.
exec "$@"
