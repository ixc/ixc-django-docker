#!/usr/bin/env bash

# Execute `python` (default) or `$PYTHON_VERSION`. Use this as the shebang in
# Python scripts that are needed by Python 2 and 3 projects.
#
# With `go.sh` (via virtualenv), `python` could be Python 2 or 3, so there is
# no need to export `PYTHON_VERSION`.
#
# With Docker (via system Python), `python` will always be a symlink to
# `python2`, so you MUST export `PYTHON_VERSION=python3`.

exec ${PYTHON_VERSION:-python} "$@"
