#!/bin/bash

set -e

# Fail loudly when required programs are missing.
for cmd in git svn; do
	hash $cmd 2>/dev/null || {
		echo "ERROR: Missing required program: '$cmd'. Please install then try again." >&2
		exit 1
	}
done

DEST_DIR="$1"

if [[ -z "$DEST_DIR" ]]; then
	echo 'ERROR: You must specify a destination directory.' >&2
	exit 1
fi

if [[ -z "$2" ]]; then
	BRANCH="trunk"
else
	BRANCH="branches/$2"
fi

if [[ -d "$DEST_DIR" ]]; then
	if [[ ! -d "$DEST_DIR/.git" ]]; then
		echo "ERROR: Directory already exists and is not a Git working copy. Aborting to avoid overwriting untracked files." >&2
		exit 1
	elif [[ -n "$(cd "$DEST_DIR"; git status --porcelain)" ]]; then
		echo "ERROR: Git working copy '$DEST_DIR' is dirty. Please commit, stash or discard all changes and untracked files, then try again." >&2
		exit 1
	fi
	echo "This script will update an existing 'ixc-django-docker' project in directory '${DEST_DIR}'."
else
	echo "This script will create a new 'ixc-django-docker' project in directory '${DEST_DIR}'."
fi

read -p 'Press CTRL-C to abort or any other key to continue...'

mkdir -p "$DEST_DIR"
cd "$DEST_DIR"

svn export --force "https://github.com/ixc/ixc-django-docker/${BRANCH}/project_template" .

PROJECT_NAME="$(basename "$(cd "$DEST_DIR"; pwd -P)")"

find . -not -path '*/\.git*' -type f -exec sed -i '' "s/project_template/$PROJECT_NAME/g" "{}" +

if [[ -d .git ]]; then
	echo
	echo "You have updated an existing 'ixc-django-docker' project."
	echo "You should review and commit or discard the following changes:"
	echo
	git status -bs
else
	git init
	git add -A
	git commit -m 'Initial commit from `ixc-django-docker` project template.'
	cat <<-EOF

	A git repository has been intialized with an initial commit from the
	'ixc-django-docker' project template.

	Now add an 'origin' remote and push:

		$ git remote add origin git@github.com/ORG/REPO.git
		$ git push origin

	EOF
fi

echo
echo "All done! What now? See: https://github.com/ixc/ixc-django-docker/blob/master/README.rst"
echo
