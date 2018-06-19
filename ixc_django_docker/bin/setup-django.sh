#!/bin/bash

>&2 echo "WARNING: 'setup-django.sh' is deprecated. Use 'setup.sh', instead."

exec setup.sh "$@"
