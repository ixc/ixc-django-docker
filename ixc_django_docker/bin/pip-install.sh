#!/bin/bash

# Install Python requirements in the given directory, if they have changed.

cat <<EOF
# `whoami`@`hostname`:$PWD$ pip-install.sh $@
EOF

set -e

DIR="${1:-$PWD}"

mkdir -p "$DIR"
cd "$DIR"

for FILE in 'requirements.txt' 'requirements-local.txt'; do
	if [[ -f "$FILE" ]]; then
		KEY="$FILE:$DIR"
		MD5="$(md5sum '$FILE')"
		if [[ "$MD5" != "$(redis-cli get '$KEY')" ]]; then
			echo "Python requirements in '$DIR' directory are out of date, '$FILE' has been updated."
			pip install --no-cache-dir -r "$FILE"
			echo "$MD5" | redis-cli -x set "$KEY"
		fi
	fi
done
