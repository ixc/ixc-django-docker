from bandit.backends.base import HijackBackendMixin
from django.conf import settings
from django.utils.module_loading import import_string

OriginalEmailBackend = import_string(settings.HIJACKED_EMAIL_BACKEND)


class HijackedEmailBackend(HijackBackendMixin, OriginalEmailBackend):
    pass
