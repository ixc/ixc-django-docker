#!/bin/bash

# Run a pre-configured interactive Bash shell, with some help text.

set -e

# Wait for Redis.
dockerize -timeout 1m -wait "tcp://${REDIS_ADDRESS:-setup:8000}"

if [[ -t 1 ]]; then
	cat <<EOF

You are running a pre-configured interactive Bash shell. Here is a list of
frequently used scripts you might want to run:

	bower-install.sh <DIR>
	celery.sh
	celerybeat.sh
	celeryflower.sh
	clear-cache.sh
	compile-sass.sh [ARGS]
	ddtrace.sh <COMMAND>
	gunicorn.sh
	logentries.sh
	manage.py [COMMAND [ARGS]]
	migrate.sh
	newrelic.sh <COMMAND>
	nginx.sh
	npm-install.sh <DIR>
	pip-install.sh <DIR>
	pydevd.sh <COMMAND>
	runserver.sh [ARGS]
	runtests.sh [ARGS]
	setup-django.sh [COMMAND]
	setup-postgres.sh
	setup-tests.sh [COMMAND]
	supervisor.sh [OPTIONS] [ACTION [ARGS]]
	transfer.sh <FILE>
	waitlock.py [-b] <COMMAND>

Most of these scripts are minimal wrappers that specify configuration and
provide automation or integration with Docker and various 'ixc-django-docker'
components.

For more info on each script, run:

	help.sh

See more detailed documentation about commands at:

	https://github.com/ixc/ixc-django-docker/docs/commands.rst

EOF

	# Compare git commit and print reminder if setup has not completed successfully.
	GIT_COMMIT="$(git rev-parse HEAD)"
	if ! redis-cache.py -q match ixc-django-docker:setup-git-commit "$GIT_COMMIT" 2>&1; then
		>&2 echo "Setup is not complete for '$GIT_COMMIT'. Run 'setup.sh' manually."
	fi

	export PS1="($PROJECT_NAME) \u@\h:\w\n\\$ "

	# Run bash by default without any user customisations from rc or profile files
	# to reduce the chance of user customisations clashing with our paths etc.
	exec bash --norc --noprofile
else
	cat <<EOF

Sleeping forever, so you can exec into this container to troubleshoot.

For example, you might need to rollback database migrations before rolling back
a deployment.

Or you might want to install and temporarily run a program that needs access to
the stack, and exposes a service on a dynamic port.

EOF
	sleep infinity
fi
