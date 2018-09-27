#!/bin/bash

# Apply Django migrations, if they are out of date.

set -e

DIR="${1:-$PROJECT_DIR/var}"

mkdir -p "$DIR"

DJANGO_VERSION_LESS_THAN_1_7=$(python.sh -c 'import django; print(django.VERSION < (1, 7))')
DJANGO_VERSION_LESS_THAN_1_10=$(python.sh -c 'import django; print(django.VERSION < (1, 10))')

if [[ "$DJANGO_VERSION_LESS_THAN_1_7" == 'True' ]]; then
	echo 'Always sync database, because Django version is less than 1.7.'
	manage.py syncdb --noinput
fi

if [[ "$DJANGO_VERSION_LESS_THAN_1_10" == 'True' ]]; then
	manage.py migrate --list > "$DIR/migrate.txt" 2> /dev/null
else
	manage.py showmigrations > "$DIR/migrate.txt" 2> /dev/null
fi

if [[ ! -s "$DIR/migrate.txt.md5" ]] || ! md5sum --status -c "$DIR/migrate.txt.md5" > /dev/null 2>&1; then
	echo 'Migrations are out of date.'

	# Skip initial migration if all tables created by the initial migration
	# already exist.
	if [[ "$DJANGO_VERSION_LESS_THAN_1_7" == 'True' ]]; then
		manage.py migrate --noinput  # South has no `--fake-initial` option
	else
		manage.py migrate --fake-initial --noinput
	fi

	if [[ "$DJANGO_VERSION_LESS_THAN_1_10" == 'True' ]]; then
		manage.py migrate --list > "$DIR/migrate.txt" 2> /dev/null
	else
		manage.py showmigrations > "$DIR/migrate.txt" 2> /dev/null
	fi

	md5sum "$DIR/migrate.txt" > "$DIR/migrate.txt.md5"
fi
