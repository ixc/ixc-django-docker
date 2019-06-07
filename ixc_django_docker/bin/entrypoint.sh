#!/bin/bash

# Configure the environment and execute a command.

set -e

# Print the full commit hash so it can be logged during startup.
if [[ -d .git ]]; then
	echo "Git Commit: $(git rev-parse HEAD)"
fi

# Fail loudly when required environment variables are missing.
for var in PROJECT_DIR; do
	eval [[ -z \${$var+1} ]] && {
		>&2 echo "ERROR: Missing environment variable: $var"
		exit 1
	}
done

# Fail loudly when required programs are missing.
for cmd in dockerize md5sum nginx npm psql python pv supervisord supervisorctl; do  # TODO: elasticsearch redis-server transcrypt yarn
	hash $cmd 2>/dev/null || {
		>&2 echo "ERROR: Missing program: $cmd"
		>&2 echo 'See: https://github.com/ixc/ixc-django-docker/blob/master/README.rst#system-requirements-when-running-without-docker'
		exit 1
	}
done

# Ensure host is accessible at `host.docker.internal`, for consistency across
# Docker for Desktop and Docker Engine on Linux.
if [[ -f /.dockerenv ]]; then
	grep -v host.docker.internal /etc/hosts > /etc/hosts
	ip -4 route list match 0/0 | awk '{print $3" host.docker.internal"}' >> /etc/hosts
fi

# Configure PATH.
export PATH="$PROJECT_DIR/node_modules/.bin:$PATH"
export PATH="$PROJECT_DIR/bin:$PATH"

# Configure Pip.
export PIP_DISABLE_PIP_VERSION_CHECK='on'

# Configure Python.
export PYTHONDONTWRITEBYTECODE='1'
export PYTHONHASHSEED='random'
export PYTHONPATH="$PROJECT_DIR:$PYTHONPATH"
export PYTHONWARNINGS='ignore'

# Configure project.
source "$PROJECT_DIR/.envrc"

# Execute command.
exec "${@:-bash.sh}"
