#!/bin/bash

# Install Node modules in the given directory, if they have changed.

set -e
shopt -s dotglob

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

UNAME="$(uname)"

touch "package.json.md5.$UNAME"

if [[ ! -s "package.json.md5.$UNAME" ]] || ! md5sum --status -c "package.json.md5.$UNAME" > /dev/null 2>&1; then
	echo "Node modules in '$DIR' directory are out of date, 'package.json' has been updated."
	if [[ -d node_modules && -z ${NPM_INSTALL_SH_SKIP_CLEAN+1} ]]; then
		rm -rf node_modules/*
	fi
	if [[ -f yarn.lock ]]; then
		yarnpkg --frozen-lockfile --non-interactive
	elif [[ -f package-lock.json ]]; then
		npm ci --unsafe-perm
	else
		npm install --unsafe-perm
	fi
	rm -f package.json.md5.*  # 'node_modules' is shared, if we rebuild for one platform, other platforms become invalid
	md5sum package.json > "package.json.md5.$UNAME"
fi
