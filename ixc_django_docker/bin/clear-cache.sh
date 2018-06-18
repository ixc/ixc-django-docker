#!/bin/bash

# Clear all caches.

cat <<EOF
# `whoami`@`hostname`:$PWD$ clear-cache.sh $@
EOF

manage.py clear_cache

# Execute the command.
exec "$@"
