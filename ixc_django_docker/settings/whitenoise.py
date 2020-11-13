INSTALLED_APPS += ('ixc_whitenoise', )

# Insert middleware above all except SecurityMiddleware, per the documentation
try:
    index = MIDDLEWARE.index(
        'django.middleware.security.SecurityMiddleware'
    ) + 1
except ValueError:
    index = 0
MIDDLEWARE = (
    MIDDLEWARE[:index] +
    ('ixc_whitenoise.middleware.WhiteNoiseMiddleware', ) +
    MIDDLEWARE[index:]
)

STATICFILES_STORAGE = 'ixc_whitenoise.storage.CompressedManifestStaticFilesStorage'
WHITENOISE_ROOT = os.path.join(PROJECT_DIR, 'whitenoise_root')
