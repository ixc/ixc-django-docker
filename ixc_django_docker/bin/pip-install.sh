#!/bin/bash

# Install Python requirements in the given directory, if they have changed.

set -e

DIR="${1:-$PWD}"

mkdir -p "$DIR"
cd "$DIR"

if [[ -f requirements.txt ]]; then
    SIGNATURE_FILE="requirements.txt.$(uname).md5"
	if [[ ! -s "${SIGNATURE_FILE}" ]] || ! md5sum --status -c "${SIGNATURE_FILE}" > /dev/null 2>&1; then
		echo
		echo "Python packages in '$DIR' directory (requirements.txt) are out of date."
		echo
		pip install --no-cache-dir -r requirements.txt
		echo
		md5sum requirements.txt > "${SIGNATURE_FILE}"
	fi
fi

if [[ -f requirements-local.txt ]]; then
    SIGNATURE_FILE="requirements-local.txt.$(uname).md5"
	if [[ ! -s "${SIGNATURE_FILE}" ]] || ! md5sum --status -c "${SIGNATURE_FILE}" > /dev/null 2>&1; then
		echo
		echo "Python packages in '$DIR' directory (requirements-local.txt) are out of date."
		echo
		pip install --no-cache-dir -r requirements-local.txt
		echo
		md5sum requirements-local.txt > "${SIGNATURE_FILE}"
	fi
fi
