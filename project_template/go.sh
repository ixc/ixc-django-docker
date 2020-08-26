#!/bin/bash

# Validate and configure the environment to match the Docker image.

set -e

# './go.sh --reset' will reset the local dev environment, after confirmation.
if [[ "$1" == "--reset" ]]; then
	RESET_COMMANDS='find . -name "*.md5" -delete; rm -rf bower_components node_modules src static_root var'
	>&2 cat <<EOF
Are you SURE you want to reset your dev environment? This cannot be undone.

These commands will be executed:

    $RESET_COMMANDS

EOF
	select yn in 'Yes' 'No'; do
		case $yn in
				Yes )
					/bin/bash -c "$RESET_COMMANDS"
					exit 0;;
				No )
					exit 1;;
		esac
	done
fi

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
for cmd in direnv dockerize md5sum nginx npm psql pv supervisord supervisorctl; do
	hash $cmd 2>/dev/null || {
		MISSING=1
		>&2 echo "ERROR: Missing dependency: $cmd"
	}
done

# Check that required Python version is installed.
CUR_PYTHON_VERSION="$(python --version 2>&1 || true)"
REQ_PYTHON_VERSION="$(cat .python-version)"
if [[ "$CUR_PYTHON_VERSION" != "Python $REQ_PYTHON_VERSION" ]]; then
	MISSING=1
	>&2 echo "ERROR: Missing Python version: $REQ_PYTHON_VERSION"
fi

# Check that a '.env' file exists.
if [[ ! -f .env ]]; then
	MISSING=1
	>&2 echo "ERROR: Missing '.env' file. Copy '.env.example' and update."
fi

# Exit if anything is missing.
if [[ -n "${MISSING+1}" ]]; then
	exit 1
fi

# Configure the environment to match the Docker image. See 'ENV' lines in 'Dockerfile'.
# export NODE_VERSION=12.18.1  # Only used to install Node.js in 'Dockerfile'
export PROJECT_DIR="$(cd $(dirname "${BASH_SOURCE[0]}"); pwd -P)"  # See: http://stackoverflow.com/a/4774063
export PYTHON_VERSION=python3.8
export PIP_DISABLE_PIP_VERSION_CHECK=on
export PIP_SRC="${PROJECT_DIR}/src"  # Inside project directory
export PYTHONDONTWRITEBYTECODE=1
export PYTHONHASHSEED=random
export PYTHONPATH="${PROJECT_DIR}:${PYTHONPATH}"
export PYTHONWARNINGS=ignore
export PYTHON_PIP_VERSION=20.1.1
export PATH="${PROJECT_DIR}/node_modules/.bin:${PATH}"
export IXC_DJANGO_DOCKER_DIR="${PIP_SRC}/ixc-django-docker/ixc_django_docker"
export PATH="${IXC_DJANGO_DOCKER_DIR}/bin:${PATH}"
export GIT_COMMIT="$(git rev-parse HEAD)"

# Configure environment.
source .env

# Set location of virtualenv and add bin directory to PATH.
export PROJECT_VENV_DIR="${PROJECT_VENV_DIR:-$PROJECT_DIR/var/go.sh-venv}"
export PATH="${PROJECT_VENV_DIR}/bin:${PATH}"

# Create virtualenv and install requirements.
if [[ ! -d "$PROJECT_VENV_DIR" ]]; then
	# NOTE: Use 'python -m' to ensure we are working with the required Python version.
	if ! python -m virtualenv --version &>/dev/null 2>&1; then
		python -m pip install virtualenv
	fi
	python -m virtualenv "$PROJECT_VENV_DIR"
	"${PROJECT_VENV_DIR}/bin/python" -m pip install "pip==${PYTHON_PIP_VERSION}"
	"${PROJECT_VENV_DIR}/bin/python" -m pip install --no-cache-dir --no-deps -r requirements.txt
	md5sum requirements.txt > requirements.txt.md5
else
	# Check that virtualenv is using required Python version.
	VENV_PYTHON_VERSION="$("${PROJECT_VENV_DIR}/bin/python" --version 2>&1 || true)"
	if [[ "$VENV_PYTHON_VERSION" != "Python $REQ_PYTHON_VERSION" ]]; then
		>&2 echo "ERROR: Virtualenv is not using required Python version $REQ_PYTHON_VERSION. Please delete: $PROJECT_VENV_DIR"
		exit 1
	fi
fi

# Execute command (default: open an interactive shell).
exec ${@:-bash.sh}
