#!/bin/bash

# Configure the environment and execute a command.

cat <<EOF
# `whoami`@`hostname`:$PWD$ entrypoint.sh $@
EOF

set -e

# Print the full commit hash so it can be logged during startup.
if [[ -d .git ]]; then
	echo "Git Commit: $(git rev-parse HEAD)"
fi

if [[ -f /.dockerenv ]]; then
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
	mkdir -p "$HOME/.config/pip"
	cat <<-EOF > "$HOME/.config/pip/pip.conf"
	[install]
	user = true
	EOF

	# Set location of userbase directory.
	export PYTHONUSERBASE="$PROJECT_DIR/var/docker-pythonuserbase"

	# Add userbase bin directory to PATH.
	export PATH="$PYTHONUSERBASE/bin:$PATH"

	# Install editable packages into userbase directory.
	export PIP_SRC="$PYTHONUSERBASE/src"

	# For some reason pip allows us to install sdist packages, but not editable
	# packages, when this directory doesn't exist. So make sure it does.
	mkdir -p "$PYTHONUSERBASE/lib/python2.7/site-packages"

	# On Docker for Mac, osxfs has performance issues when watching file system
	# events. Detect Docker for Mac and export an environment variable that we
	# can check to disable file system watches.
	if mount | grep -q osxfs; then
		cat <<-EOF
		#
		# IMPORTANT
		#
		# You are running Docker for Mac with shared volumes, which has
		# performance issues causing high CPU utilisation. See:
		#
		#     https://docs.docker.com/docker-for-mac/osxfs/#/performance-issues-solutions-and-roadmap
		#
		# You should avoid anything that watches the file system. For example,
		# the Django dev server with auto-reloading enabled.
		#
		# You can check the 'DOCKER_FOR_MAC=1' environment variable to
		# conditionally disable any such features. The 'runserver.sh' script
		# already does this.
		#
		EOF
		export DOCKER_FOR_MAC=1
	fi
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
	for cmd in md5sum nginx npm psql python pv redis-server yarn; do  # TODO: elasticsearch git-secret transcrypt
		hash $cmd 2>/dev/null || {
			>&2 echo "ERROR: Missing program: $cmd"
			>&2 echo 'See: https://github.com/ixc/ixc-django-docker/blob/develop/README.rst#requirements-when-running-without-docker'
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

# Source local dotenv file, which is not encrypted or version controlled, and
# may contain the password needed to decrypt secret files.
if [[ -f "$PROJECT_DIR/.env.local" ]]; then
	set -o allexport
	source "$PROJECT_DIR/.env.local"
	set +o allexport
fi

# Configure git secret.
export GNUPGHOME="$PROJECT_DIR/.gnupg"
export SECRETS_GPG_COMMAND=gpg2

# Decrypt files with git secret.
if [[ -d "$PROJECT_DIR/.gitsecret" ]]; then
	setup-git-secret.sh || true  # Don't exit if we can't decrypt secrets
fi

# Decrypt files with transcrypt.
if [[ -n "$TRANSCRYPT_PASSWORD" ]]; then
	git status  # See: https://github.com/elasticdog/transcrypt/issues/37
	transcrypt --force -c "${TRANSCRYPT_CIPHER:-aes-256-cbc}" -p "$TRANSCRYPT_PASSWORD" -y || true  # Don't exit if we can't decrypt secrets
fi

# Source global, environment and local dotenv files, if decrypted.
for dotenv in base "$DOTENV.secret" local; do
	DOTENV_FILE="$PROJECT_DIR/.env.$dotenv"
	if [[ -f "$DOTENV_FILE" ]]; then
		echo "Sourcing DOTENV file: $DOTENV_FILE"
		set -o allexport
		source "$DOTENV_FILE"
		set +o allexport
	fi
done

# Get number of CPU cores, so we know how many processes to run.
export CPU_CORES=$(python -c "import multiprocessing; print(multiprocessing.cpu_count());")

# Configure Pip.
export PIP_DISABLE_PIP_VERSION_CHECK=on

# Get project name from the project directory.
export PROJECT_NAME=$(basename "$PROJECT_DIR")

# Configure Python.
export PYTHONDONTWRITEBYTECODE=1
export PYTHONHASHSEED=random
export PYTHONPATH="$PROJECT_DIR:$PYTHONPATH"
export PYTHONWARNINGS=ignore

# Derive 'PGDATABASE' from 'PROJECT_NAME' and git branch or 'DOTENV', if not
# already defined.
if [[ -z "$PGDATABASE" ]]; then
	if [[ -d .git ]]; then
		export PGDATABASE="${PROJECT_NAME}_$(git rev-parse --abbrev-ref HEAD | sed 's/[^0-9A-Za-z]/_/g')"
		echo "Derived database name '$PGDATABASE' from 'PROJECT_NAME' environment variable and git branch."
	elif [[ -n "$DOTENV" ]]; then
		export PGDATABASE="${PROJECT_NAME}_$DOTENV"
		echo "Derived database name '$PGDATABASE' from 'PROJECT_NAME' and 'DOTENV' environment variables."
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
