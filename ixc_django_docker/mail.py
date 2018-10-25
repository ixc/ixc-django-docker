from django.conf import settings
from django.utils.module_loading import import_string

EmailBackend = import_string(settings.IXC_DJANGO_DOCKER_EMAIL_BACKEND)
