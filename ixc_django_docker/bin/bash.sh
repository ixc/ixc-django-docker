#!/bin/bash

# Run an interactive project shell, with some help text.

set -e

if [[ -t 1 ]]; then
	cat <<EOF

You are running an interactive project shell. Here is a list of frequently used
scripts you might want to run:

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
	transfer.sh <FILE>
	# waitlock.py [-b] <COMMAND>

Most of these scripts are minimal wrappers that specify configuration and
provide automation or integration with Docker and various 'ixc-django-docker'
components.

For more info on each script, run:

	help.sh

For detailed documentation, see:

	https://github.com/ixc/ixc-django-docker/docs/commands.rst

EOF

	# Compare git commit and print reminder if setup has not completed successfully.
	GIT_COMMIT="$(git-commit.sh)"
	if [[ "$GIT_COMMIT" != $(cat "$PROJECT_DIR/var/setup-git-commit.txt" 2>&1) ]]; then
		>&2 cat <<EOF
WARNING: Setup is not complete for git commit: '$GIT_COMMIT'
         Run 'setup.sh' manually.

EOF
	fi

	export PS1="($PROJECT_NAME:$DOTENV) \u@\h:\w\n\\$ "

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
