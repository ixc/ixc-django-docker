#!/bin/bash

# Run an interactive project shell, with some help text.

# Running in a terminal.
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

	export PS1="($PROJECT_NAME:${OVERRIDE_SETTINGS:-$DOTENV}) \u@\h:\w\n\\$ "

	# Not sourced.
	if [[ "$0" = "$BASH_SOURCE" ]]; then
		# Run bash without any user customisations from rc or profile files to reduce the
		# chance of user customisations clashing with our paths etc.
		exec bash --norc --noprofile
	fi

# Not running in a terminal and not sourced.
elif [[ "$0" = "$BASH_SOURCE" ]]; then
	>&2 echo 'Sleeping forever, so you can exec into this container.'
	sleep infinity
fi
