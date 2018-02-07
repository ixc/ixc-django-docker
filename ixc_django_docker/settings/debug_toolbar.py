import sys

# Remove `INTERNAL_IPS` check.
DEBUG_TOOLBAR_CONFIG = {'SHOW_TOOLBAR_CALLBACK': lambda r: not r.is_ajax()}

DEBUG_TOOLBAR_PATCH_SETTINGS = False  # Can cause circular import errors

INSTALLED_APPS += ('debug_toolbar', )

if django.VERSION < (1, 10):
    MIDDLEWARE_CLASSES = (
        'debug_toolbar.middleware.DebugToolbarMiddleware',
    ) + MIDDLEWARE_CLASSES
else:
    MIDDLEWARE = (
        'debug_toolbar.middleware.DebugToolbarMiddleware',
    ) + MIDDLEWARE

# When running with multiple processes, panels must be rendered immediately.
if 'runserver' not in sys.argv:
    DEBUG_TOOLBAR_CONFIG['RENDER_PANELS'] = True
