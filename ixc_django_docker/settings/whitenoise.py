INSTALLED_APPS += ('ixc_whitenoise', )

if django.VERSION < (1, 10):
    MIDDLEWARE_CLASSES += ('ixc_whitenoise.middleware.WhiteNoiseMiddleware', )
else:
    MIDDLEWARE += ('ixc_whitenoise.middleware.WhiteNoiseMiddleware', )

STATICFILES_STORAGE = 'ixc_whitenoise.storage.CompressedManifestStaticFilesStorage'
WHITENOISE_AUTOREFRESH = True
WHITENOISE_ROOT = os.path.join(PROJECT_DIR, 'whitenoise_root')
WHITENOISE_USE_FINDERS = True
