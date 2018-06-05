#!/bin/bash

# Apply Django migrations, if they are out of date.

cat <<EOF
# `whoami`@`hostname`:$PWD$ migrate.sh $@
EOF

set -e

DIR="${1:-$PROJECT_DIR/var}"

mkdir -p "$DIR"

DJANGO_VERSION_LESS_THAN_1_7=$(python -c 'import django; print(django.VERSION < (1, 7))')
DJANGO_VERSION_LESS_THAN_1_10=$(python -c 'import django; print(django.VERSION < (1, 10))')

if [[ DJANGO_VERSION_LESS_THAN_1_7 == 'True' ]]; then
	echo 'Always sync database, because Django version is less than 1.7.'
	manage.py syncdb --noinput
fi

if [[ DJANGO_VERSION_LESS_THAN_1_10 == 'True' ]]; then
    manage.py migrate --list > "$DIR/migrate.txt" 2>/dev/null
else
    manage.py showmigrations > "$DIR/migrate.txt" 2>/dev/null
fi

# Rely on the formatted text output of Django's migration listing to tell us
# whether there are any pending migrations, which are flagged with an empty
# ASCII checkbox versus a checked one. Grep for the unapplied migration '[ ]'
# text as a flag for when migrations need to be applied, and when grep returns
# an **error** status we know there are **no unapplied migrations**
#
# Here is an example of the output of 'showmigrations' etc:
#
#     wagtailusers
#      [X] 0001_initial
#      [ ] 0002_add_verbose_name_on_userprofile
set +e
grep '\[ \]' "$DIR/migrate.txt" > /dev/null
HAS_ALL_MIGRATIONS_APPLIED=$?
set -e

if [[ HAS_ALL_MIGRATIONS_APPLIED -ne 0 ]]; then
	echo 'Migrations are up-to-date - no migration listing items contain "[ ]"'
else
    echo 'Migrations are out of date - one or more migration listing items contain "[ ]"'

	if [[ DJANGO_VERSION_LESS_THAN_1_7 == 'True' ]]; then
		manage.py migrate --noinput  # South has no `--fake-initial` option
	else
		manage.py migrate --fake-initial --noinput
	fi
fi
