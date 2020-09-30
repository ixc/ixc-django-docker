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

BOWER_JSON="bower.json.$(uname).md5"

touch "$BOWER_JSON"

if [[ ! -s "$BOWER_JSON" ]] || ! md5sum --status -c "$BOWER_JSON" > /dev/null 2>&1; then
	echo "Bower components in '$DIR' directory are out of date, 'bower.json' has been updated."
	if [[ -d bower_components ]]; then
		rm -rf bower_components
	fi
	bower install --allow-root
	md5sum bower.json > "$BOWER_JSON"
fi
