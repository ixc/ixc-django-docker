#!/bin/bash

# Install Node modules in the given directory, if they have changed.

cat <<EOF
# `whoami`@`hostname`:$PWD$ npm-install.sh $@
EOF

set -e

DIR="${1:-$PWD}"
KEY="npm-install.sh:$DIR"

mkdir -p "$DIR"
cd "$DIR"

if [[ ! -s package.json ]]; then
	cat <<EOF > package.json
{
  "name": "$PROJECT_NAME",
  "dependencies": {
  },
  "private": true
}
EOF
fi

MD5="$(md5sum package.json)"

if [[ "$MD5" != "$(redis-cli get '$KEY')" ]]; then
	echo "Node modules in '$DIR' directory are out of date."
	if [[ -d node_modules ]]; then
		echo 'Removing old Node modules directory.'
		rm -rf node_modules
	fi
	npm install
	echo "$MD5" | redis-cli -x set "$KEY"
fi
