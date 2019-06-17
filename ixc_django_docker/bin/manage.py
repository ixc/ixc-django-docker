#!/usr/bin/env bash

# Wrap `manage.py` in the project root, so we can execute it from anywhere.

exec "${PROJECT_DIR}/manage.py" "$@"
