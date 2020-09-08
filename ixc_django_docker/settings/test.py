import os

# Fail loudly if not running in a suitably configured environment. This is a
# safety measure to avoid accidentally running tests against a production or
# development database.
if not os.environ.get('SETUP_TESTS'):
    raise ImportError(
        'Cannot import %s outside of `setup-tests.sh` environment.' % __file__)

# DJANGO ######################################################################

ALLOWED_HOSTS = ('*', )

# Use a real cache backend.
CACHES['default'].update({
    'BACKEND': 'redis_lock.django_cache.RedisCache',
    'LOCATION': 'redis://%s/0' % REDIS_ADDRESS,
})

CSRF_COOKIE_SECURE = False  # Don't require HTTPS for CSRF cookie
SESSION_COOKIE_SECURE = False  # Don't require HTTPS for session cookie

DATABASES['default'].update({
    'TEST': {
        'NAME': DATABASES['default']['NAME'],
        # See: https://docs.djangoproject.com/en/1.7/ref/settings/#serialize
        'SERIALIZE': False,
    },
})

DEBUG = True
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
PASSWORD_HASHERS = ('django.contrib.auth.hashers.MD5PasswordHasher', )

# Do not use a manifest storage backend for tests, so we can skip `collectstatic`.
STATICFILES_STORAGE = 'django.contrib.staticfiles.storage.StaticFilesStorage'

# Enable the cached template loader.
TEMPLATES[0]['OPTIONS']['loaders'] = [
    (
        'django.template.loaders.cached.Loader',
        TEMPLATES[0]['OPTIONS']['loaders'],
    ),
]

# COMPRESSOR ##################################################################

COMPRESS_CSS_FILTERS = ()
COMPRESS_ENABLED = False
COMPRESS_PRECOMPILERS = ()

# STORAGE #####################################################################

ENABLE_S3_STORAGE = False

# WHITENOISE ##################################################################

WHITENOISE_AUTOREFRESH = True
WHITENOISE_USE_FINDERS = True
