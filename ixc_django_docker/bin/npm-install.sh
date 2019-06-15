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

SIGNATURE_FILE="package.json.$(uname).md5"
touch "${SIGNATURE_FILE}"

if [[ ! -s "${SIGNATURE_FILE}" ]] || ! md5sum --status -c "${SIGNATURE_FILE}" > /dev/null 2>&1; then
	echo
	echo "Node modules in '$DIR' directory (package.json) are out of date."
	if [[ -d node_modules ]]; then
		echo 'Removing old Node modules directory.'
		rm -rf node_modules
	fi
	echo
	if [[ -f yarn.lock ]]; then
		yarn --non-interactive
	elif [[ -f package-lock.json ]]; then
		npm ci
	else
		npm install
	fi
	echo
	md5sum package.json > "${SIGNATURE_FILE}"
fi
