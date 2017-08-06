#!/bin/bash

PROG="ixc_django_docker/bin/redis-cache.py"

KEY=test-redis-cache
TEST_FILENAME=test-redis-cache.out

# Run command once to print out error messages if Redis is unavailable etc
$PROG set $KEY "dummy value"

##############
# Test 'match'
##############
ls -1 > $TEST_FILENAME

if $PROG -x match $KEY < $TEST_FILENAME; then
    echo "FAIL: Expected no match for first run of 'match'"
fi

$PROG -x set $KEY < $TEST_FILENAME

if ! $PROG -x match $KEY < $TEST_FILENAME; then
    echo "FAIL: Expected match for second run of 'match'"
fi

if ! $PROG -x match $KEY < $TEST_FILENAME; then
    echo "FAIL: Expected match for third run of 'match'"
fi

echo "Changed" >> $TEST_FILENAME
if $PROG -x match $KEY < $TEST_FILENAME; then
    echo "FAIL: Expected no match for run of 'match' with changed data"
fi

$PROG -x set $KEY < $TEST_FILENAME

if ! $PROG -x match $KEY < $TEST_FILENAME; then
    echo "FAIL: Expected match for run of 'match' after changed data re-set"
fi

# Set expiry timeout for cached data
$PROG -x --expire-secs 1 set $KEY < $TEST_FILENAME

sleep 2s  # Must be longer than expiry timeout
if $PROG -x match $KEY < $TEST_FILENAME; then
    echo "FAIL: Expected no match for run of 'match' after delay where cached data should expire"
fi

rm $TEST_FILENAME
