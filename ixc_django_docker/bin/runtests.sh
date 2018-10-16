#!/bin/bash

# Run tests. Set 'QUICK=1' reuse the test database and collected static and
# compressed files.

set -e

# Configure environment, if not already done.
[[ -z "$SETUP_TESTS" ]] && source setup-tests.sh

# Collect and compress static files. Skip when QUICK is set and when it has
# already been done at least once before.
[[ -z "$QUICK" || ! -d "$PROJECT_DIR/static_root" ]] && [[ -z "$WITHOUT_COLLECTSTATIC" ]] && manage.py collectstatic --noinput --verbosity=0
[[ -z "$QUICK" || ! -f "$PROJECT_DIR/static_root/CACHE/manifest.json" ]] && [[ -z "$WITHOUT_COMPRESSOR" ]] && manage.py compress --force --verbosity=0

# Run tests and generate a coverage report.
if [[ -z "$WITHOUT_COVERAGE" ]]; then
    time coverage run "$(which manage.py)" test --noinput --verbosity=2 $RUNTESTS_EXTRA "${@:-.}"
    coverage report
else
    time manage.py test --noinput --verbosity=2 $RUNTESTS_EXTRA "${@:-.}"
fi
