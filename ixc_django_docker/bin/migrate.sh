#!/bin/bash

# Apply Django migrations, if they are out of date.

cat <<EOF
# `whoami`@`hostname`:$PWD$ migrate.sh $@
EOF

set -e

DIR="${1:-$PROJECT_DIR/var}"

mkdir -p "$DIR"

if [[ $(python -c 'import django; print(django.get_version());') < 1.7 ]]; then
	echo 'Always sync database, because Django version is less than 1.7.'
	manage.py syncdb --noinput
fi

manage.py migrate --list > "$DIR/migrate.txt"

# Is local listing of migrations the same as one cached in Redis
# (i.e. as has already been completed and cached by another server instance)?
if ! redis-cache.py -v -x match ixc-django-docker:migrate-list < "$DIR/migrate.txt"; then
	echo 'Migrations are out of date.'

	# Skip initial migration if all tables created by the initial migration
	# already exist.
	if [[ $(python -c 'import django; print(django.get_version());') < 1.7 ]]; then
		manage.py migrate --noinput  # South has no `--fake-initial` option
	else
		manage.py migrate --fake-initial --noinput
	fi

	manage.py migrate --list > "$DIR/migrate.txt"

	# Cache listing of up-to-date migrations
	redis-cache.py -vv -x set ixc-django-docker:migrate-list < "$DIR/migrate.txt"
fi
