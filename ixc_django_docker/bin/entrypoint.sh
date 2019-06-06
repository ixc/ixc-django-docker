#!/bin/bash

# Configure the environment and execute a command.

set -e

# Print the full commit hash so it can be logged during startup.
if [[ -d .git ]]; then
	echo "Git Commit: $(git rev-parse HEAD)"
fi

# Fail loudly when required environment variables are missing.
for var in PROJECT_DIR PGDATABASE; do
	eval [[ -z \${$var+1} ]] && {
		>&2 echo "ERROR: Missing environment variable: $var"
		exit 1
	}
done

# Fail loudly when required programs are missing.
for cmd in dockerize md5sum nginx npm psql python pv redis-server supervisord supervisorctl transcrypt; do  # TODO: elasticsearch yarn
	hash $cmd 2>/dev/null || {
		>&2 echo "ERROR: Missing program: $cmd"
		>&2 echo 'See: https://github.com/ixc/ixc-django-docker/blob/master/README.rst#system-requirements-when-running-without-docker'
		exit 1
	}
done

if [[ -f /.dockerenv ]]; then
	# When run with Docker, the only system site packages are the ones that we
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

	# For some reason pip allows us to install sdist packages, but not editable
	# packages, when these directories don't exist. So make sure they do.
	# There's no easy way to detect the minor version of Python being used, so
	# create directories for all supported versions. They don't hurt anything.
	mkdir -p "$PYTHONUSERBASE/lib/python2.7/site-packages"
	mkdir -p "$PYTHONUSERBASE/lib/python3.5/site-packages"
	mkdir -p "$PYTHONUSERBASE/lib/python3.6/site-packages"
	mkdir -p "$PYTHONUSERBASE/lib/python3.7/site-packages"

	# Ensure host is accessible at `host.docker.internal`.
	grep -v host.docker.internal /etc/hosts > /etc/hosts
	ip -4 route list match 0/0 | awk '{print $3" host.docker.internal"}' >> /etc/hosts
fi

# Get absolute directory for the `ixc_django_docker` package. We can't use
# `python.sh` here because it is not installed into the virtualenv or system
# `bin` directory.
export IXC_DJANGO_DOCKER_DIR="$("${PYTHON_VERSION:-python}" -c 'import ixc_django_docker, os; print(os.path.dirname(ixc_django_docker.__file__));')"

# Add project, `node_modules`, and `ixc-django-docker` bin directories to PATH.
export PATH="$PROJECT_DIR/bin:$PROJECT_DIR/node_modules/.bin:$IXC_DJANGO_DOCKER_DIR/bin:$PATH"

# Configure Pip.
export PIP_DISABLE_PIP_VERSION_CHECK='on'

# Configure Python.
export PYTHONDONTWRITEBYTECODE='1'
export PYTHONHASHSEED='random'
export PYTHONPATH="$PROJECT_DIR:$PYTHONPATH"
export PYTHONWARNINGS='ignore'

# Configure default environment variables when run with and without Docker.
if [[ -f /.dockerenv ]]; then
	export DATADOG_TRACE_AGENT_HOSTNAME="${DATADOG_TRACE_AGENT_HOSTNAME:-datadog}"
	export ELASTICSEARCH_ADDRESS="${ELASTICSEARCH_ADDRESS:-elasticsearch:9200}"
	export PGHOST="${PGHOST:-postgres}"
	export PGUSER="${PGUSER:-postgres}"
	export REDIS_ADDRESS="${REDIS_ADDRESS:-redis:6379}"
else
	export DATADOG_TRACE_AGENT_HOSTNAME="${DATADOG_TRACE_AGENT_HOSTNAME:-localhost}"
	export ELASTICSEARCH_ADDRESS="${ELASTICSEARCH_ADDRESS:-localhost:9200}"
	export PGHOST="${PGHOST:-localhost}"
	export PGUSER="${PGUSER:-$(whoami)}"
	export REDIS_ADDRESS="${REDIS_ADDRESS:-localhost:6379}"
fi

# Configure project.
source "$PROJECT_DIR/.envrc"

# Execute command.
exec "${@:-bash.sh}"
