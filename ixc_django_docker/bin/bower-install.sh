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

UNAME="$(uname)"

touch "bower.json.md5.$UNAME"

if [[ ! -s "bower.json.md5.$UNAME" ]] || ! md5sum --status -c "bower.json.md5.$UNAME" > /dev/null 2>&1; then
	echo "Bower components in '$DIR' directory are out of date, 'bower.json' has been updated."
	if [[ -d bower_components ]]; then
		rm -rf bower_components/* bower_components/.*
	fi
	bower install --allow-root
	rm -f bower.json.md5.*  # 'bower_components' is shared, if we rebuild for one platform, other platforms become invalid
	md5sum bower.json > "bower.json.md5.$UNAME"
fi
