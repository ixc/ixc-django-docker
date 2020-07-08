#!/bin/bash

# Reset a local development environment

set -e

if [[ -z "$PROJECT_DIR" ]]; then
	>&2 echo "ERROR: Missing environment variable: PROJECT_DIR"
	exit 1
fi

rm -rf "$DIR/var"

find . -name "*.md5" -delete
