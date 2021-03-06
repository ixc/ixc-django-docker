#!/bin/bash

# Configure the environment and execute a command.

set -e

if [[ -f /.dockerenv || -n "${DOCKER+1}" ]]; then
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
			MISSING=1
			>&2 echo "ERROR: Missing environment variable: $var"
		}
	done

	# Fail loudly when required programs are missing.
	for cmd in dockerize md5sum nginx npm psql "${PYTHON_VERSION:-python}" pv supervisord supervisorctl; do
		hash $cmd 2>/dev/null || {
			MISSING=1
			>&2 echo "ERROR: Missing program: $cmd"
		}
	done

	# Abort if any dependencies are missing.
	if [[ -n "${MISSING+1}" ]]; then
		>&2 echo 'See: https://github.com/ixc/ixc-django-docker/blob/master/README.rst#system-requirements-when-running-without-docker'
		exit 1
	fi

	# Add virtualenv bin directory to PATH.
	export PATH="$PROJECT_VENV_DIR/bin:$PATH"
fi

# Get absolute directory for the `ixc_django_docker` package. We can't use
# `python.sh` here because it is not installed into the virtualenv or system
# `bin` directory.
export IXC_DJANGO_DOCKER_DIR="$("${PYTHON_VERSION:-python}" -c 'import ixc_django_docker, os; print(os.path.dirname(ixc_django_docker.__file__));')"

# Add project, `node_modules`, and `ixc-django-docker` bin directories to PATH.
export PATH="$PROJECT_DIR/bin:$PROJECT_DIR/node_modules/.bin:$IXC_DJANGO_DOCKER_DIR/bin:$PATH"

# Print the full commit hash so it can be logged during startup.
echo "Git Commit: $(git-commit.sh)"

# Source local dotenv file, which is not encrypted or version controlled, and
# may contain the password needed to decrypt secret files.
if [[ -f "$PROJECT_DIR/.env.local" ]]; then
	set -o allexport
	source "$PROJECT_DIR/.env.local"
	set +o allexport
fi

# Decrypt files with transcrypt.
if [[ -d .git && -n "$TRANSCRYPT_PASSWORD" ]]; then
	git status &> /dev/null  # See: https://github.com/elasticdog/transcrypt/issues/37
	# Use `--force` to overwrite "missing" secrets that are listed in
	# `.dockerignore` to avoid accidentally copying decrypted secrets into an
	# image.
	transcrypt --force -c "${TRANSCRYPT_CIPHER:-aes-256-cbc}" -p "$TRANSCRYPT_PASSWORD" -y || true  # Don't exit if we can't decrypt secrets
fi

# Source global, environment and local dotenv files, if decrypted.
for dotenv in base "$DOTENV" "$DOTENV.secret" local; do
	DOTENV_FILE="$PROJECT_DIR/.env.$dotenv"
	if [[ -f "$DOTENV_FILE" ]]; then
		echo "Sourcing DOTENV file: $DOTENV_FILE"
		set -o allexport
		source "$DOTENV_FILE"
		set +o allexport
	fi
done

# Get number of CPU cores, so we know how many processes to run.
export CPU_CORES=$(python.sh -c "import multiprocessing; print(multiprocessing.cpu_count());")

# Configure Pip.
export PIP_DISABLE_PIP_VERSION_CHECK=on
export PIP_SRC="${PIP_SRC:-$PROJECT_DIR/src}"

# Get project name from the project directory.
export PROJECT_NAME=$(basename "$PROJECT_DIR")

# Configure Python.
export PYTHONDONTWRITEBYTECODE=1
export PYTHONHASHSEED=random
export PYTHONPATH="$PROJECT_DIR:$PYTHONPATH"
export PYTHONWARNINGS=ignore

# Set PostgreSQL database and port.
export PGDATABASE="${PGDATABASE:-${PROJECT_NAME}_${DOTENV}}"
export PGPORT="${PGPORT:-5432}"

# Set overridable default environment variables.
if [[ -f /.dockerenv || -n "${DOCKER+1}" ]]; then
	# Set Datadog trace agent host.
	export DATADOG_TRACE_AGENT_HOSTNAME="${DATADOG_TRACE_AGENT_HOSTNAME:-datadog}"

	# Set Elasticsearch host and port.
	export ELASTICSEARCH_ADDRESS="${ELASTICSEARCH_ADDRESS:-elasticsearch:9200}"

	# Set PostgreSQL host and user.
	export PGHOST="${PGHOST:-postgres}"
	export PGUSER="${PGUSER:-postgres}"

	# Set Redis host and port.
	export REDIS_ADDRESS="${REDIS_ADDRESS:-redis:6379}"
else
	# Set Datadog trace agent host.
	export DATADOG_TRACE_AGENT_HOSTNAME="${DATADOG_TRACE_AGENT_HOSTNAME:-localhost}"

	# Set Elasticsearch host and port.
	export ELASTICSEARCH_ADDRESS="${ELASTICSEARCH_ADDRESS:-localhost:9200}"

	# Set PostgreSQL host and user.
	export PGHOST="${PGHOST:-localhost}"
	export PGUSER="${PGUSER:-$(whoami)}"

	# Set Redis host and port.
	export REDIS_ADDRESS="${REDIS_ADDRESS:-localhost:6379}"
fi

# Execute command.
exec "${@:-bash.sh}"
