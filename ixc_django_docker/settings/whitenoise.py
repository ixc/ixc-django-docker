INSTALLED_APPS += ('ixc_whitenoise', )

if django.VERSION < (1, 10):
    MIDDLEWARE_CLASSES += ('ixc_whitenoise.WhiteNoiseMiddleware', )
else:
    MIDDLEWARE += ('ixc_whitenoise.WhiteNoiseMiddleware', )

STATICFILES_STORAGE = 'ixc_whitenoise.CompressedManifestStaticFilesStorage'
WHITENOISE_AUTOREFRESH = True
WHITENOISE_ROOT = os.path.join(PROJECT_DIR, 'whitenoise_root')
WHITENOISE_USE_FINDERS = True
