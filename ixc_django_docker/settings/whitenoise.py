INSTALLED_APPS += ('ixc_whitenoise', )

# Use a unique name for the 'staticfiles.json' manifest, so we can run new and old
# versions of a codebase side by side with a shared volume.
IXC_WHITENOISE_MANIFEST_NAME = os.path.join(
    os.environ.get('STATICFILES_MANIFEST') or os.path.join(
        'staticfiles', '%s.json' % (os.environ.get('GIT_COMMIT') or '_unknown')
    )
)

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
