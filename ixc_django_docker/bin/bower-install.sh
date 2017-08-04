#!/bin/bash

# Install Bower components in the given directory, if they have changed.

cat <<EOF
# `whoami`@`hostname`:$PWD$ bower-install.sh $@
EOF

set -e

DIR="${1:-$PWD}"
KEY="bower-install.sh:$DIR"

mkdir -p "$DIR"
cd "$DIR"

if [[ ! -s bower.json ]]; then
	cat <<EOF > bower.json
{
  "name": "$PROJECT_NAME",
  "dependencies": {
  },
  "private": true
}
EOF
fi

MD5="$(md5sum bower.json)"

if [[ "$MD5" != "$(redis-cli get '$KEY')" ]]; then
	echo "Bower components in '$DIR' directory are out of date."
	if [[ -d bower_components ]]; then
		echo 'Removing old Bower components directory.'
		rm -rf bower_components
	fi
	bower install --allow-root
	echo "$MD5" | redis-cli -x set "$KEY"
fi
