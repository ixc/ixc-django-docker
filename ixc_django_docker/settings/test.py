from .base import *

# DJANGO ######################################################################

ALLOWED_HOSTS = ('*', )

CSRF_COOKIE_SECURE = False  # Don't require HTTPS for CSRF cookie
SESSION_COOKIE_SECURE = False  # Don't require HTTPS for session cookie
