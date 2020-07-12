#!/bin/bash

# Install Bower components in the given directory, if they have changed.

set -e

DIR="${1:-$PWD}"

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

touch bower.json.md5

if [[ ! -s bower.json.md5 ]] || ! md5sum --status -c bower.json.md5 > /dev/null 2>&1; then
	echo "Bower components in '$DIR' directory are out of date, 'bower.json' has been updated."
	bower install --allow-root
	md5sum bower.json > bower.json.md5
fi
