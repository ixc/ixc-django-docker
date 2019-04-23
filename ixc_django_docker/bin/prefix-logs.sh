#!/usr/bin/env bash

# See: https://serverfault.com/a/946271

# Point fd-3 and fd-4 at original stdout and stderr.
exec 3>&1
exec 4>&2

# Get prefix.
PREFIX="${PREFIX:-$SUPERVISOR_PROCESS_NAME}"

# Get minimum prefix length.
LEN="${LEN:-15}"

# Increase minimum prefix length if smaller than actual prefix.
PREFIX_LEN="${#PREFIX}"
LEN="$(( PREFIX_LEN > LEN ? PREFIX_LEN : LEN ))"

# Pad prefix to a consistent length.
printf -v PREFIX "%-${LEN}.${LEN}s" ${PREFIX}

# Redirect stdout and stderr to a process that adds the prefix and redirects
# back to the original stdout and stderr (3 and 4).
exec 1> >(perl -ne '$| = 1; print "'"${PREFIX}"' | $_"' >&3)
exec 2> >(perl -ne '$| = 1; print "'"${PREFIX}"' | $_"' >&4)

# From here on everthing that outputs to stdout and stderr will go through the
# perl script.

exec "$@"
