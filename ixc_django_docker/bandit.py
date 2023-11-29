from __future__ import absolute_import

from bandit.backends.base import HijackBackendMixin
from django.conf import settings

from ixc_django_docker.compat import import_string

OriginalEmailBackend = import_string(settings.HIJACKED_EMAIL_BACKEND)


class HijackedEmailBackend(HijackBackendMixin, OriginalEmailBackend):
    pass
