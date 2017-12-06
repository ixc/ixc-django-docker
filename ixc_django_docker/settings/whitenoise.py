MIDDLEWARE_CLASSES += ('ixc_whitenoise.WhiteNoiseMiddleware', )
STATICFILES_STORAGE = 'ixc_whitenoise.CompressedManifestStaticFilesStorage'
WHITENOISE_AUTOREFRESH = True
WHITENOISE_ROOT = os.path.join(PROJECT_DIR, 'whitenoise_root')
WHITENOISE_USE_FINDERS = True
