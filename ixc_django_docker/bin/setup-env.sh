#!/bin/bash

set -e

# Fail loudly when required environment variables are missing.
for var in PROJECT_DIR; do
    eval [[ -z \${$var+1} ]] && {
        >&2 echo "ERROR: Missing environment variable: $var"
        MISSING_VARS=1
    }
done
if [[ -n "${MISSING_VARS+1}" ]]; then
    >&2 echo 'Missing environment variables are normally exported from `Dockerfile`, `Dockerfile.sh`, or the project entrypoint.'
    return 1
fi

# Fail loudly when required programs are missing.
for program in dockerize git htpasswd jq md5sum nginx npm psql pv python supervisord supervisorctl; do
    hash $program 2>/dev/null || {
        >&2 echo "ERROR: Missing program: $program"
        MISSING_PROGRAMS=1
    }
done
if [[ -n "${MISSING_PROGRAMS+1}" ]]; then
    >&2 echo 'Missing programs are normally installed by `Dockerfile`, but must be installed manually when running natively.'
    return 1
fi

# Docker config.
if [[ -f /.dockerenv ]]; then
    # Ensure host is accessible at 'host.docker.internal' on Linux, for
    # consistency with macOS and Windows.
    # See: https://github.com/docker/for-linux/issues/264
    echo "$(grep -v host.docker.internal /etc/hosts)" > /etc/hosts
    ip -4 route list match 0/0 | awk '{print $3" host.docker.internal"}' >> /etc/hosts
fi

# Export and log the full git commit.
if [[ -d .git ]]; then
    export GIT_COMMIT="$(git rev-parse HEAD)"
    echo "Git Commit: $(git rev-parse HEAD)"
fi

# Export root directory, so we can determine relative paths.
export IXC_DJANGO_DOCKER_DIR="$(python -c 'import ixc_django_docker, os; print(os.path.dirname(ixc_django_docker.__file__));')"

# Add bin directory to PATH.
if [[ ":$PATH:" != *":${IXC_DJANGO_DOCKER_DIR}/bin:"* ]]; then
    export PATH="${PATH}:${IXC_DJANGO_DOCKER_DIR}/bin"
fi

# Use `ixc-django-docker` settings by default.
if [[ -z "${DJANGO_SETTINGS_MODULE+1}" ]]; then
    echo "Exporting DJANGO_SETTINGS_MODULE='ixc_django_docker.settings'"
    export DJANGO_SETTINGS_MODULE='ixc_django_docker.settings'
fi

# If executed interactively, update the prompt, print help text, and warn if
# the user needs to run 'setup.sh'.
if [[ -t 1 ]]; then
    cat <<EOF

You are running an interactive 'ixc-django-docker' project shell. Here is a
list of frequently used commands you might want to run:

    bower-install.sh <DIR>
    celery.sh
    celerybeat.sh
    celeryflower.sh
    clear-cache.sh
    # compile-sass.sh [ARGS]
    ddtrace.sh <COMMAND>
    gunicorn.sh
    # logentries.sh
    manage.py [COMMAND [ARGS]]
    migrate.sh
    newrelic.sh <COMMAND>
    nginx.sh
    npm-install.sh <DIR>
    pip-install.sh <DIR>
    pydevd.sh <COMMAND>
    runserver.sh [ARGS]
    runtests.sh [ARGS]
    setup.sh [COMMAND]
    setup-postgres.sh
    setup-tests.sh [COMMAND]
    supervisor.sh [OPTIONS] [ACTION [ARGS]]
    # transfer.sh <FILE>
    # waitlock.py [-b] <COMMAND>

Most of these commands are minimal convenience wrappers that configure default
options, render config file templates, or execute conditionally.

For more info on each script, run:

    help.sh

For detailed documentation, see:

    https://github.com/ixc/ixc-django-docker/docs/commands.rst

EOF
fi

# Warn if setup is not complete.
if [[ "$GIT_COMMIT" != $(cat "$PROJECT_DIR/var/setup-git-commit-$(uname).txt" 2>&1) ]]; then
    >&2 cat <<EOF
WARNING:

    Setup is not complete for git commit: '$GIT_COMMIT'

    Run 'setup.sh' to install Node modules, Bower components and Python
    packages, create a database, apply Django migrations, and run the
    npm 'build' script (if defined).

EOF
fi
