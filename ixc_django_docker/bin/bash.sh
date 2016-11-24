#!/bin/bash

# Run a pre-configured interactive Bash shell, with some help text.

cat <<EOF
# `whoami`@`hostname`:$PWD$ bash.sh $@
EOF

set -e

cat <<EOF

You are running a pre-onfigured interactive Bash shell. Here is a list of
frequently used scripts you might want to run:

    bower-install.sh <DIR>
    celery.sh
    celerybeat.sh
    celeryflower.sh
    gunicorn.sh
    manage.py [COMMAND [ARGS]]
    migrate.sh
    nginx.sh
    npm-install.sh <DIR>
    pip-install.sh <DIR>
    runserver.sh [ARGS]
    runtests.sh [ARGS]
    setup-django.sh [COMMAND]
    setup-git-secret.sh [COMMAND]
    setup-postgres.sh
    supervisor.sh [OPTIONS] [ACTION [ARGS]]
    transfer.sh <FILE>
    waitlock.sh <COMMAND>

Most of these scripts are minimal wrappers that specify configuration and
provide automation or integration with Docker and various 'ixc-django-docker'
components.

For more info on each script, run:

    help.sh

EOF

# Run bash by default without any user customisations from rc or profile files
# to reduce the chance of user customisations clashing with our paths etc.
exec bash --norc --noprofile
