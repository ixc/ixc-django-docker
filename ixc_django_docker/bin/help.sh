#!/bin/bash

set -e

cat <<EOF

Here is a list of frequently used commands you might want to run:

	bower-install.sh <DIR>
		Change to <DIR> and execute 'bower install', *if* 'bower.json' has been
		updated since the last time it was run.

	celery.sh
		Start Celery. This is normally managed by Docker or Supervisord, and is
		not normally used interactively.

	celerybeat.sh
		Start Celery Beat. This is normally managed by Docker or Supervisord,
		and is not normally used interactively.

	celeryflower.sh
		Start Celery Flower. This is normally managed by Docker or Supervisord,
		and is not normally used interactively.

	clear-cache.sh
		Clear all Django caches and execute a command.

	# compile-sass.sh [ARGS]
	# 	Compile all SASS/SCSS files in the 'static' directory, saving output to
	# 	the 'static/COMPILED' directory.

	# 	Pass '--watch' to detect changes and recompile automatically.

	ddtrace.sh <COMMAND>
		Execute a command via 'ddtrace-run' (Datadog APM).

	gunicorn.sh
		Start Gunicorn. This is normally managed by Docker or Supervisord, and
		is not normally used interactively.

	# logentries.sh
	# 	Start LogEntries Agent. This is normally managed by Supervisord, and is
	# 	not normally used interactively.

	manage.py [COMMAND [ARGS]]
		Run a Django management command.

	migrate.sh
		Apply Django migrations, *if* the migrations on disk have been updated
		since the last time it was run.

	newrelic.sh <COMMAND>
		Execute a command via 'newrelic-admin run-program'.

	nginx.sh
		Start Nginx. This is normally managed by Docker or Supervisord, and is
		not normally used interactively.

	npm-install.sh <DIR>
		Change to <DIR> and execute 'npm install', *if* 'package.json' has been
		updated since the last time it was run.

	pip-install.sh <DIR>
		Change to <DIR> and execute 'pip install', *if* 'requirements.txt' or
		'requirements-local.txt' have been updated since the last time it was
		run.

	pydevd.sh <COMMAND>
		Enable a 'pydevd' trace found in the 'ixc_django_docker' package and
		execute a command.

		You can reconfigure the host and port for the remote debug server with
		the follow environment variables:

			PYDEVD_HOST=localhost
			PYDEVD_PORT=5678

	runserver.sh [ARGS]
		Start gunicorn with simplified logging, auto-reloading, and 1 worker.

	runtests.sh [ARGS]
		Configure environment, create and restore test database, apply Django
		migrations, then run 'collectstatic', 'compress', and 'test' management
		commands.

		Set 'QUICK=1' to reuse the existing test database and collected static
		and compressed files.

			# QUICK=1 runtests.sh

		Set 'RUNTESTS_EXTRA=...' to supply additional args to the 'test'
		management command.

		Set 'WITHOUT_COLLECTSTATIC=1' and 'WITHOUT_COMPRESSOR=1' to disable
		'collectstatic' and 'compress' management commands, respectively.

	setup.sh [COMMAND]
		Install Node modules, Bower components and Python requirements, create
		a database, apply Django migrations, and execute a command.

	setup-postgres.sh
		Create a PostgreSQL database with a name derived from the project
		directory and current Git branch.

		Seed the new database with data from the 'SRC_PG*' environment
		variables, if defined.

		Additional 'pg_dump' args can be specified in the 'SRC_PGDUMP_EXTRA'
		environment variable. E.g. '--exclude-table-data django_session'

		Drop and recreate the database if 'SETUP_POSTGRES_FORCE' is defined.

	setup-tests.sh [COMMAND]
		Configure environment, create and restore test database, apply Django
		migrations, and execute a command.

	supervisor.sh [OPTIONS] [ACTION [ARGS]]
		With no arguments, start Supervisord. This is normally managed by
		Docker, and is usually only used interactively when not using Docker.

		Otherwise, run 'supervisorctl'. When using Docker, use this to manage
		Gunicorn and Nginx. When not using Docker, it also manages Celery,
		Celery Beat and Celery Flower.

	transfer.sh
		Encrypt and upload a file to https://transfer.sh

	# waitlock.py [-b] <COMMAND>
	# 	Serialize the execution of a command with a Redis lock.

See more detailed documentation about commands at:

    https://github.com/ixc/ixc-django-docker/docs/commands.rst

EOF
