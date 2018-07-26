#!/bin/bash

# Just enough bootstrap so we can execute `entrypoint.sh`.

cat <<EOF
# `whoami`@`hostname`:$PWD$ go.sh $@
EOF

set -e

# Get absolute project directory from the location of this script.
# See: http://stackoverflow.com/a/4774063
export PROJECT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}"); pwd -P)

# Source local environment variables.
if [[ -f "$PROJECT_DIR/.env.local" ]]; then
	source "$PROJECT_DIR/.env.local"
else
	>&2 echo 'ERROR: You must create a `.env.local` file. See: `.env.local.sample`.'
	exit 1
fi

# Set location of virtualenv.
export PROJECT_VENV_DIR="${PROJECT_VENV_DIR:-$PROJECT_DIR/var/go.sh-venv}"

# Create a virtualenv and install requirements, including `ixc-django-docker`.
if [[ ! -d "$PROJECT_VENV_DIR" ]]; then
	virtualenv --python=python3 "$PROJECT_VENV_DIR"
	PIP_SRC="${PIP_SRC:-$PROJECT_DIR/src}" "$PROJECT_VENV_DIR/bin/python" -m pip install --no-cache-dir --no-deps -r requirements.txt
	md5sum requirements.txt > requirements.txt.md5
fi

# Execute entrypoint and command (default: open an interactive shell).
exec "$PROJECT_VENV_DIR/bin/entrypoint.sh" ${@:-bash.sh}
