from django.conf import settings
try:
    # For Django<1.9 compatibility
    from django.utils.module_loading import import_by_path as import_string
except ImportError:
    from django.utils.module_loading import import_string

EmailBackend = import_string(settings.IXC_DJANGO_DOCKER_EMAIL_BACKEND)
