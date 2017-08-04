#!/bin/bash

# Apply Django migrations, if they are out of date.

cat <<EOF
# `whoami`@`hostname`:$PWD$ migrate.sh $@
EOF

set -e

DIR="${1:-$PROJECT_DIR/var}"
KEY="migrate.sh:$DIR"

mkdir -p "$DIR"

if [[ $(python -c 'import django; print(django.get_version());') < 1.7 ]]; then
	echo 'Always sync database, because Django version is less than 1.7.'
	manage.py syncdb --noinput
fi

MIGRATE_LIST=$(manage.py migrate --list)

if [[ "$MIGRATE_LIST" != "$(redis-cli get '$KEY')" ]]; then
	echo 'Migrations are out of date.'

	# Skip initial migration if all tables created by the initial migration
	# already exist.
	if [[ $(python -c 'import django; print(django.get_version());') < 1.7 ]]; then
		manage.py migrate --noinput  # South has no `--fake-initial` option
	else
		manage.py migrate --fake-initial --noinput
	fi

	echo "$MIGRATE_LIST" | redis-cli -x set "$KEY"
fi
