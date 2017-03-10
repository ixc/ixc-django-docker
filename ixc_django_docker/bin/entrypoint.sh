#!/bin/bash

# Configure the environment and execute a command.

cat <<EOF
# `whoami`@`hostname`:$PWD$ entrypoint.sh $@
EOF

set -e

if [[ -n "${DOCKER+1}" ]]; then
	# When run via Docker, the only system site packages are the ones that we
	# have installed, so we do not need a virtualenv for isolation. Using an
	# isolated virtualenv would mean we have to reinstall everything during
	# development, even when no versions have changed. Using a virtualenv
	# created with `--system-site-packages` would mean we can avoid
	# reinstalling everything, but pip would try to uninstall existing packages
	# when we try to install a new version, which can fail with permissions
	# errors (e.g. when running as an unprivileged user or when the image is
	# read-only). The alternate installation user scheme avoids these problems
	# by ignoring existing system site packages when installing a new version,
	# instead of trying to uninstall them.
	# See: https://pip.pypa.io/en/stable/user_guide/#user-installs

	# Make `pip install --user` the default, to ensure we always install into
	# the userbase directory.
	pip() {
		if [[ "$1" == install ]]; then
			shift
			set -- install --user "$@"
		fi
		command pip "$@"
	}
	export -f pip

	# Set location of userbase directory.
	export PYTHONUSERBASE="$PROJECT_DIR/var/docker-pythonuserbase"

	# Add userbase bin directory to PATH.
	export PATH="$PYTHONUSERBASE/bin:$PATH"

	# For some reason pip allows us to install sdist packages, but not editable
	# packages, when this directory doesn't exist. So make sure it does.
	mkdir -p "$PYTHONUSERBASE/lib/python2.7/site-packages"
else
	# When run via 'go.sh', we need a virtualenv for isolation from system site
	# packages, and we also verify that required environment variables and
	# programs are available.

	# Fail loudly when required environment variables are missing.
	for var in PROJECT_DIR PROJECT_VENV_DIR; do
		eval [[ -z \${$var+1} ]] && {
			>&2 echo "ERROR: Missing environment variable: $var"
			exit 1
		}
	done

	# Fail loudly when required programs are missing.
	for cmd in md5sum nginx npm psql python pv redis-server; do # elasticsearch
		hash $cmd 2>/dev/null || {
			>&2 echo "ERROR: Missing program: $cmd"
			>&2 echo 'See: https://github.com/ic-labs/django-icekit/blob/develop/docs/intro/manual-setup.md'
			exit 1
		}
	done

	# Add virtualenv bin directory to PATH.
	export PATH="$PROJECT_VENV_DIR/bin:$PATH"
fi

# Get absolute directory for the `ixc_django_docker` package.
export IXC_DJANGO_DOCKER_DIR=$(python -c "import ixc_django_docker, os; print(os.path.dirname(ixc_django_docker.__file__));")

# Add project and `ixc-django-docker` bin directories to PATH.
export PATH="$PROJECT_DIR/bin:$IXC_DJANGO_DOCKER_DIR/bin:$PATH"

if [[ -d "$PROJECT_DIR/.gitsecret" ]]; then
	# Set location of GPG home directory.
	export GNUPGHOME="$PROJECT_DIR/.gnupg"

	# Decrypt files with git-secret.
	setup-git-secret.sh || true  # Don't exit if we can't decrypt secrets
fi

# Decrypt files with transcrypt.
if [[ -n "$TRANSCRYPT_PASSWORD" ]]; then
	git status  # See: https://github.com/elasticdog/transcrypt/issues/37
	transcrypt -c "${TRANSCRYPT_CIPHER:-aes-256-cbc}" -p "$TRANSCRYPT_PASSWORD" -y || true
fi

# Source dotenv file.
set -o allexport
if [[ -f "$PROJECT_DIR/.env.${DOTENV:-local}" ]]; then
	source "$PROJECT_DIR/.env.${DOTENV:-local}"
fi
set +o allexport

# Set default base settings module.
export BASE_SETTINGS_MODULE="${BASE_SETTINGS_MODULE:-develop}"

# Get number of CPU cores, so we know how many processes to run.
export CPU_CORES=$(python -c "import multiprocessing; print(multiprocessing.cpu_count());")

# Configure Pip.
export PIP_DISABLE_PIP_VERSION_CHECK=on
export PIP_SRC="$PROJECT_DIR/var/src"

# Get project name from the project directory.
export PROJECT_NAME=$(basename "$PROJECT_DIR")

# Configure Python.
export PYTHONHASHSEED=random
export PYTHONWARNINGS=ignore
export PYTHONPATH="$PROJECT_DIR:$PYTHONPATH"

# Derive 'PGDATABASE' from 'PROJECT_NAME' and git branch or
# 'BASE_SETTINGS_MODULE', if not already defined.
if [[ -z "$PGDATABASE" ]]; then
	if [[ -d .git ]]; then
		export PGDATABASE="${PROJECT_NAME}_$(git rev-parse --abbrev-ref HEAD | sed 's/[^0-9A-Za-z]/_/g')"
		echo "Derived database name '$PGDATABASE' from 'PROJECT_NAME' environment variable and git branch."
	elif [[ -n "$DOTENV" ]]; then
		export PGDATABASE="${PROJECT_NAME}_$DOTENV"
		echo "Derived database name '$PGDATABASE' from 'PROJECT_NAME' and 'DOTENV' environment variables."
	elif [[ -n "$BASE_SETTINGS_MODULE" ]]; then
		export PGDATABASE="${PROJECT_NAME}_$BASE_SETTINGS_MODULE"
		echo "Derived database name '$PGDATABASE' from 'PROJECT_NAME' and 'BASE_SETTINGS_MODULE' environment variables."
	else
		export PGDATABASE="$PROJECT_NAME"
		echo "Derived database name '$PGDATABASE' from 'PROJECT_NAME' environment variable."
	fi
fi

# Default PostgreSQL credentials.
export PGHOST="${PGHOST:-localhost}"
export PGPORT="${PGPORT:-5432}"
export PGUSER="${PGUSER:-$(whoami)}"

# Get Redis host and port.
export REDIS_ADDRESS="${REDIS_ADDRESS:-localhost:6379}"

# Execute command.
exec "${@:-bash.sh}"
