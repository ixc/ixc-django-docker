#!/usr/bin/env bash

# Execute `python` (default) or `$PYTHON_VERSION`. Use this as the shebang in
# Python scripts that are needed by Python 2 and 3 projects.

exec ${PYTHON_VERSION:-python} "$@"
