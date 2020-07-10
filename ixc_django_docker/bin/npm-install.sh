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

touch package.json.md5

if [[ ! -s package.json.md5 ]] || ! md5sum --status -c package.json.md5 > /dev/null 2>&1; then
	echo "Node modules in '$DIR' directory are out of date."
	if [[ -d node_modules ]]; then
		echo 'Cleaning old Node modules directory.'
		rm -rf node_modules/.* node_modules/*
	fi
	if [[ -f yarn.lock ]]; then
		yarn --non-interactive
	elif [[ -f package-lock.json ]]; then
		npm ci
	else
		npm install
	fi
	md5sum package.json > package.json.md5
fi
