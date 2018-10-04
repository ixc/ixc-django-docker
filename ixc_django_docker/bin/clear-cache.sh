#!/bin/bash

# Clear all cache data.

# Django.
manage.py clear_cache

# Cacheops.
if manage.py | grep -q invalidate; then
	manage.py invalidate all
fi

# Execute the command.
exec "$@"
