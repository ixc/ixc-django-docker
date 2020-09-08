ALLOWED_HOSTS = ('*', )  # Don't validate the host header
CSRF_COOKIE_SECURE = False  # Don't require HTTPS for CSRF cookie
DEBUG = True  # Show detailed error pages when exceptions are raised
SESSION_COOKIE_SECURE = False  # Don't require HTTPS for session cookie

# WHITENOISE ##################################################################

WHITENOISE_AUTOREFRESH = True
