#!/bin/bash

# Run tests. Set 'QUICK=1' reuse the test database and collected static and
# compressed files.

cat <<EOF
# `whoami`@`hostname`:$PWD$ runtests.sh $@
EOF

set -e

export BASE_SETTINGS_MODULE=test
export REUSE_DB=1
export SRC_PGDATABASE="$PROJECT_DIR/test_initial_data.sql"

# Only drop eisting database when QUICK is not set.
[[ -z "$QUICK" ]] && export SETUP_POSTGRES_FORCE=1

PGDATABASE="test_$PGDATABASE" setup-postgres.sh
if [[ $(python -c 'import django; print(django.get_version());') < 1.7 ]]; then
	echo 'Always sync database, because Django version is less than 1.7.'
	manage.py syncdb --noinput
fi
[[ -z "$QUICK" ]] && manage.py migrate --noinput

# Only collect and compress static files when QUICK is not set or when it has
# never been done before.
[[ -z "$QUICK" || ! -d "$PROJECT_DIR/static_root" ]] && manage.py collectstatic --noinput --verbosity=0
[[ -z "$QUICK" || ! -f "$PROJECT_DIR/static_root/CACHE/manifest.json" ]] && manage.py compress --force --verbosity=0

# Run tests, collecting coverage data and generate a coverage report.
coverage run "$IXC_DJANGO_DOCKER_DIR/bin/manage.py" test --noinput --verbosity=2 "${@:-.}"
coverage report

# Submit coverage data to coveralls.
if [[ -n "$TRAVIS" ]]; then
	coveralls || true  # Don't exit if we can't submit data
fi
