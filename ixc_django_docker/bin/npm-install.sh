#!/bin/bash

# Install Node modules in the given directory, if they have changed.

set -e

DIR="${1:-$PWD}"

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

PACKAGE_JSON="package.json.$(uname).md5"

touch "$PACKAGE_JSON"

if [[ ! -s "$PACKAGE_JSON" ]] || ! md5sum --status -c "$PACKAGE_JSON" > /dev/null 2>&1; then
	echo "Node modules in '$DIR' directory are out of date, 'package.json' has been updated."
	if [[ -d node_modules ]]; then
		rm -rf node_modules
	fi
	if [[ -f yarn.lock ]]; then
		yarn --non-interactive
	elif [[ -f package-lock.json ]]; then
		npm ci
	else
		npm install
	fi
	md5sum package.json > "$PACKAGE_JSON"
fi
