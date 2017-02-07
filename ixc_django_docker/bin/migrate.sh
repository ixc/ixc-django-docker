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

touch "$DIR/migrate.txt.md5"
manage.py migrate --list > "$DIR/migrate.txt"

if [[ ! -s "$DIR/migrate.txt.md5" ]] || ! md5sum --status -c "$DIR/migrate.txt.md5" > /dev/null 2>&1; then
	echo 'Migrations are out of date.'
	manage.py migrate --noinput
	manage.py migrate --list > "$DIR/migrate.txt"
	md5sum "$DIR/migrate.txt" > "$DIR/migrate.txt.md5"
fi
