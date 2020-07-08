#!/bin/bash

# Validate and configure the environment to match the Docker image.

set -e

# Do macOS setup if brew is installed.
if hash brew 2>/dev/null; then
	# Catalina. See: https://apple.stackexchange.com/a/372600
	export CPATH="$(xcrun --show-sdk-path)/usr/include"

	# Add keg-only dockerize@0.6.0 to PATH.
	DOCKERIZE_PREFIX="$(brew --prefix dockerize@0.6.0 2>/dev/null || true)"
	if [[ ! -d "$DOCKERIZE_PREFIX" ]]; then
		MISSING=1
		>&2 echo "ERROR: Missing Homebrew keg: dockerize@0.6.0"
	fi
	export PATH="$DOCKERIZE_PREFIX/bin:$PATH"

	# Add keg-only node@12 to PATH.
	NODE_PREFIX="$(brew --prefix node@12 2>/dev/null || true)"
	if [[ ! -d "$NODE_PREFIX" ]]; then
		MISSING=1
		>&2 echo "ERROR: Missing Homebrew keg: node@12"
	fi
	export PATH="$NODE_PREFIX/bin:$PATH"

	# Stop Apple from warning about the default shell being zsh.
	export BASH_SILENCE_DEPRECATION_WARNING=1
fi

# Check that dependencies are installed.
for cmd in direnv dockerize md5sum nginx npm psql pv pyenv redis-server supervisord supervisorctl; do
	hash $cmd 2>/dev/null || {
		MISSING=1
		>&2 echo "ERROR: Missing dependency: $cmd"
	}
done

if [[ -n "${MISSING+1}" ]]; then
	exit 1
fi

# Get absolute project directory from the location of this script.
# See: http://stackoverflow.com/a/4774063
export PROJECT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}"); pwd -P)

# Set location of virtualenv.
export PROJECT_VENV_DIR="${PROJECT_VENV_DIR:-$PROJECT_DIR/var/go.sh-venv}"

# Check that required version of Python is installed.
PYTHON_VERSION="$(cat .python-version)"
if ! python --version 2>&1 | grep -q "^Python $PYTHON_VERSION"; then
	# Check that virtualenv does not already exist, as it will need to be recreated.
	if [[ -d "$PROJECT_VENV_DIR" ]]; then
		>&2 echo "ERROR: Missing required version of Python, but virtualenv already exists and needs to be recreated. Please delete manually: $PROJECT_VENV_DIR"
		exit 1
	fi
	# Install required version of Python.
	pyenv install $(cat .python-version)
	pyenv rehash  # Create pyenv shims
fi

# Create virtualenv and install requirements.
if [[ ! -d "$PROJECT_VENV_DIR" ]]; then
	# NOTE: Use 'python -m' to ensure we are working with the required Python version.
	if ! python -m virtualenv >/dev/null 2>&1; then
		python -m pip install virtualenv
	fi
	python -m virtualenv "$PROJECT_VENV_DIR"
	PIP_SRC="$PROJECT_DIR/src" "$PROJECT_VENV_DIR/bin/python" -m pip install --no-cache-dir --no-deps -r requirements.txt
	md5sum requirements.txt > requirements.txt.md5
fi

# Execute entrypoint and command (default: open an interactive shell).
exec "$PROJECT_VENV_DIR/bin/entrypoint.sh" ${@:-bash.sh}
