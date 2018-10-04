#!/bin/bash

set -e

exec "${APM:-newrelic}.sh" celery --app="${CELERY_APP:-ixc_django_docker.celery}" beat --loglevel=INFO --pidfile= "$@"
