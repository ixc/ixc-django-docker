#!/bin/bash

set -e

# Fail loudly when required environment variables are missing.
for var in PROJECT_DIR; do
	eval [[ -z \${$var+1} ]] && {
		>&2 echo "ERROR: Missing environment variable: $var"
		exit 1
	}
done

# Fail loudly when required programs are missing.
for cmd in dockerize git md5sum nginx npm psql python pv supervisord supervisorctl; do  # TODO: elasticsearch redis-server transcrypt yarn
	hash $cmd 2>/dev/null || {
		>&2 echo "ERROR: Missing program: $cmd"
		>&2 echo 'See: https://github.com/ixc/ixc-django-docker/blob/master/README.rst#system-requirements-when-running-without-docker'
		exit 1
	}
done

# Print the full commit hash so it can be logged during startup.
if [[ -d .git ]]; then
	echo "Git Commit: $(git rev-parse HEAD)"
fi

# Docker config.
if [[ -f /.dockerenv ]]; then
    # Ensure host is accessible at `host.docker.internal`, for consistency
    # across Linux, macOS and Windows.
	echo "$(grep -v host.docker.internal /etc/hosts)" > /etc/hosts
	ip -4 route list match 0/0 | awk '{print $3" host.docker.internal"}' >> /etc/hosts
fi

# ixc-django-docker config.
export IXC_DJANGO_DOCKER_DIR="$(python -c 'import ixc_django_docker, os; print(os.path.dirname(ixc_django_docker.__file__));')"
if [[ ":${PATH}:" != *":$IXC_DJANGO_DOCKER_DIR/bin:"* ]]; then
    export PATH="$IXC_DJANGO_DOCKER_DIR/bin:$PATH"
fi

# Project config.
if [[ -f "$PROJECT_DIR/.envrc" ]]; then
    source "$PROJECT_DIR/.envrc"
fi

# Execute command.
exec "${@:-bash.sh}"
