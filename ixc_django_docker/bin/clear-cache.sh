#!/bin/bash

# Clear all cache data.

cat <<EOF
# `whoami`@`hostname`:$PWD$ clear-cache.sh $@
EOF

# Django.
manage.py clear_cache

# Cacheops.
if manage.py | grep -q invalidate; then
	manage.py invalidate all
fi

# Execute the command.
exec "$@"
