#!/bin/bash

cat <<EOF
# `whoami`@`hostname`:$PWD$ compile-sass.sh $@
EOF

set -e

sass "$PROJECT_DIR/static:$PROJECT_DIR/static/COMPILED" "$@"
