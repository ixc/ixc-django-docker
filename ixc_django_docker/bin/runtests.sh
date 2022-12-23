#!/bin/bash

# Run tests. Set 'QUICK=1' reuse the test database and collected static and
# compressed files.

set -e

# Configure environment, if not already done.
[[ -z "$SETUP_TESTS" ]] && source setup-tests.sh

# Run tests and generate a coverage report.
if [[ -z "$WITHOUT_COVERAGE" ]]; then
    time coverage run "$(which manage.py)" test $RUNTESTS_EXTRA --noinput --verbosity=2 "${@:-.}"
    coverage report
    [[ -n "$COVERAGE_HTML" ]] && coverage html
    [[ -n "$COVERAGE_XML" ]] && coverage xml
else
    time manage.py test $RUNTESTS_EXTRA --noinput --verbosity=2 "${@:-.}"
fi
