INSTALLED_APPS += ('ixc_whitenoise', )

# Insert middleware above all except SecurityMiddleware, per the documentation
if django.VERSION < (1, 10):
    try:
        index = MIDDLEWARE_CLASSES.index(
            'django.middleware.security.SecurityMiddleware'
        ) + 1
    except ValueError:
        index = 0
    MIDDLEWARE_CLASSES = MIDDLEWARE_CLASSES[:index] \
        + ('ixc_whitenoise.middleware.WhiteNoiseMiddleware', ) \
        + MIDDLEWARE_CLASSES[index:]
else:
    try:
        index = MIDDLEWARE.index(
            'django.middleware.security.SecurityMiddleware'
        ) + 1
    except ValueError:
        index = 0
    MIDDLEWARE = MIDDLEWARE[:index] \
        + ('ixc_whitenoise.middleware.WhiteNoiseMiddleware', ) \
        + MIDDLEWARE[index:]

STATICFILES_STORAGE = 'ixc_whitenoise.storage.CompressedManifestStaticFilesStorage'
WHITENOISE_ROOT = os.path.join(PROJECT_DIR, 'whitenoise_root')
