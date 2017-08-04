#!/bin/bash

PROG="ixc_django_docker/bin/redis-cache.py"

KEY=test-redis-cache
TEST_FILENAME=test-redis-cache.out
EXPIRE_SECS=1

# Run command once to print out error messages if Redis is unavailable etc
$PROG get $KEY > /dev/null

##############
# Test 'match'
##############
MATCH_CMD="$PROG -x --expire-secs $EXPIRE_SECS match $KEY"
SET_CMD="$PROG -x --expire-secs $EXPIRE_SECS set $KEY"
ls -1 > $TEST_FILENAME

if $MATCH_CMD < $TEST_FILENAME > /dev/null 2>&1; then
    echo "FAIL: Expected no match for first run of 'match'"
fi

$SET_CMD < $TEST_FILENAME

if ! $MATCH_CMD < $TEST_FILENAME > /dev/null 2>&1; then
    echo "FAIL: Expected match for second run of 'match'"
fi

if ! $MATCH_CMD < $TEST_FILENAME > /dev/null 2>&1; then
    echo "FAIL: Expected match for third run of 'match'"
fi

echo "Changed" >> $TEST_FILENAME
if $MATCH_CMD < $TEST_FILENAME > /dev/null 2>&1; then
    echo "FAIL: Expected no match for run of 'match' with changed data"
fi

$SET_CMD < $TEST_FILENAME

if ! $MATCH_CMD < $TEST_FILENAME > /dev/null 2>&1; then
    echo "FAIL: Expected match for run of 'match' after changed data re-set"
fi

sleep 2s  # Must be longer than $EXPIRE_SECS
if $MATCH_CMD < $TEST_FILENAME > /dev/null 2>&1; then
    echo "FAIL: Expected no match for run of 'match' after delay where cached data should expire"
fi

rm $TEST_FILENAME
