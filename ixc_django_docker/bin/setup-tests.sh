#!/bin/bash

# Configure environment, create and restore test database, apply Django
# migrations, and execute a command.

set -e

export DOTENV='test'
export PGDATABASE="test_$PGDATABASE"
export OVERRIDE_SETTINGS='test.py'
export PS1="($PROJECT_NAME:${OVERRIDE_SETTINGS:-$DOTENV}) \u@\h:\w\n\\$ "
export REUSE_DB=1
export SETUP_TESTS=1
export SHOW_SETTINGS="${SHOW_SETTINGS:-1}"
export SRC_PGDATABASE="$PROJECT_DIR/test_initial_data.sql"

DJANGO_VERSION_LESS_THAN_1_7=$(python.sh -c 'import django; print(django.VERSION < (1, 7))')

# Only drop existing database when QUICK is not set.
[[ -z "$QUICK" ]] && export SETUP_POSTGRES_FORCE=1

setup-postgres.sh

if [[ "$DJANGO_VERSION_LESS_THAN_1_7" == 'True' ]]; then
	echo 'Always sync database, because Django version is less than 1.7.'
	manage.py syncdb --noinput
fi
[[ -z "$QUICK" ]] && manage.py migrate --noinput

# Execute setup tests command.
if [[ -z "${QUICK+1}" && -n "${SETUP_TESTS_COMMAND+1}" ]]; then
	echo "Executing setup command: ${SETUP_TESTS_COMMAND}"
	bash -c ${SETUP_TESTS_COMMAND}
fi

# Execute command, only if not sourced.
if [[ "$0" = "$BASH_SOURCE" ]]; then
	exec "${@:-bash}"
fi
