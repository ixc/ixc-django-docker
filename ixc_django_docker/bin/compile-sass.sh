#!/bin/bash

set -e

sass "$PROJECT_DIR/static:$PROJECT_DIR/static/COMPILED" "$@"
