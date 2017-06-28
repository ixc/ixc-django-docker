#!/bin/bash

# Compress, encrypt (with GPG), and upload a file to https://transfer.sh, then
# display a command to download and decrypt and decompress.

set -e

if [ $# -eq 0 ]; then
	cat <<-EOF
	Usage:
		$(basename "$0") /tmp/test.md
		cat /tmp/test.md | $(basename "$0") test.md
	EOF
	exit 1
fi

if tty -s; then
	BASENAME=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g')
	URL=$(pv "$1" | gzip | gpg -aco - | curl --progress-bar --upload-file - "https://transfer.sh/$BASENAME")
else
	URL=$(pv - | gzip | gpg -aco - | curl --progress-bar --upload-file - "https://transfer.sh/$1")
fi

cat <<EOF
To download:
	curl --progress-bar $URL | gpg -o - | gunzip > $BASENAME
EOF
