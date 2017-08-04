#!/bin/bash

PROG="ixc_django_docker/bin/redis-cache.py"

KEY=test-redis-cache
TEST_FILENAME=test-redis-cache.out
EXPIRE_SECS=1

######################
# Test 'set-and-match'
######################
CMD="$PROG -x --expire-secs $EXPIRE_SECS set-and-match $KEY"
ls -1 > $TEST_FILENAME

if $CMD < $TEST_FILENAME; then
    echo "FAIL: Expected no match for first run of 'set-and-match'"
fi

if ! $CMD < $TEST_FILENAME; then
    echo "FAIL: Expected match for second run of 'set-and-match'"
fi

if ! $CMD < $TEST_FILENAME; then
    echo "FAIL: Expected match for third run of 'set-and-match'"
fi

echo "Changed" >> $TEST_FILENAME
if $CMD < $TEST_FILENAME; then
    echo "FAIL: Expected no match for run of 'set-and-match' with changed data"
fi

if ! $CMD < $TEST_FILENAME; then
    echo "FAIL: Expected match for second run of 'set-and-match' after changed data"
fi

sleep 2s  # Must be longer than $EXPIRE_SECS
if $CMD < $TEST_FILENAME; then
    echo "FAIL: Expected no match for run of 'set-and-match' after delay where cached data should expire"
fi

rm $TEST_FILENAME
