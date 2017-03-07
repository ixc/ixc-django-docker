#!/bin/bash

# Run tests. Set 'QUICK=1' reuse the test database and collected static and
# compressed files.

cat <<EOF
# `whoami`@`hostname`:$PWD$ runtests.sh $@
EOF

set -e

source setup-tests.sh

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
