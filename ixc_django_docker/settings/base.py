"""
Safe default settings, based on Django 1.8 LTS project template and checklist.
"""

import os
import random
import re
import string

import django
if django.VERSION < (2,):
    from django.core.urlresolvers import reverse_lazy
else:
    from django.urls import reverse_lazy

try:
    from django.utils.text import slugify
except ImportError:
    from django.template.defaultfilters import slugify

from django.utils.six import text_type

# Store DOTENV from environment as a setting
DOTENV = os.environ.get('DOTENV', 'dotenv-not-set')

# Get project directory from environment. This MUST already be defined.
# Copied from __init__.py I'm not sure why it's needed here as well
PROJECT_DIR = os.environ['PROJECT_DIR'].rstrip('/')

PROJECT_SLUG = re.sub(r'[^0-9A-Za-z]+', '-', slugify(
    text_type(os.path.basename(PROJECT_DIR)).lower()))

REDIS_ADDRESS = os.environ.get('REDIS_ADDRESS', 'localhost:6379')
SITE_DOMAIN = os.environ.get('SITE_DOMAIN', '%s.lvh.me' % PROJECT_SLUG)

VAR_DIR = os.environ.get('VAR_DIR', os.path.join(PROJECT_DIR, 'var'))

# Create missing var directory.
try:
    os.makedirs(VAR_DIR)
except OSError:
    pass

# DJANGO CHECKLIST ############################################################

# See https://docs.djangoproject.com/en/1.8/howto/deployment/checklist/

#
# CRITICAL
#

# Get the secret key from the environment.
SECRET_KEY = os.environ.get('SECRET_KEY')

# Get or generate and save random secret key.
if not SECRET_KEY:
    SECRET_FILE = os.path.join(VAR_DIR, 'secret.txt')
    try:
        # Get the secret key from the file system.
        with open(SECRET_FILE) as f:
            SECRET_KEY = f.read()
    except IOError:
        # Generate a random secret key.
        SECRET_KEY = ''.join(random.choice(''.join([
            string.ascii_letters,
            string.digits,
            string.punctuation,
        ])) for i in range(50))
        # Save the secret key to the file system.
        with open(SECRET_FILE, 'w') as f:
            f.write(SECRET_KEY)
            os.chmod(SECRET_FILE, 0o400)  # Read only by owner

DEBUG = False  # Don't show detailed error pages when exceptions are raised

#
# ENVIRONMENT SPECIFIC
#

# Allow connections only on the site domain.
ALLOWED_HOSTS = ('.%s' % SITE_DOMAIN, )

# Use dummy caching, so we don't get confused because a change is not taking
# effect when we expect it to, and so we can execute management commands when
# building a Docker image.
CACHES = {
    'default': {
        'BACKEND': 'ixc_django_docker.redis_lock.DummyCache',
        'KEY_PREFIX': 'default-%s' % PROJECT_SLUG,
    }
}

if os.environ.get('PGDATABASE'):
    # Use PostgreSQL database settings if they are provided in environment
    DATABASES = {
        'default': {
            'ATOMIC_REQUESTS': True,
            'ENGINE': 'django.db.backends.postgresql_psycopg2',
            'NAME': os.environ.get('PGDATABASE'),
            'USER': os.environ.get('PGUSER'),
            'PASSWORD': os.environ.get('PGPASSWORD'),
            'HOST': os.environ.get('PGHOST'),
            'PORT': os.environ.get('PGPORT'),
        },
    }
else:
    # Use SQLite, because it has no external dependencies.
    DATABASES = {
        'default': {
            'ATOMIC_REQUESTS': True,
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': os.path.join(VAR_DIR, 'db.sqlite3'),
        },
    }

# Don't actually send emails, in case we are running in development or staging
# with a copy of the production database.
#
# Set the Django backend to a simple wrapper/proxy backend, so we can more
# easily wrap the `EMAIL_BACKEND` setting (e.g. with `django-celery-email` and
# `django-post-office`), while still making it easy to re-enable actual email
# sending in production settings.
EMAIL_BACKEND = 'ixc_django_docker.mail.EmailBackend'
IXC_DJANGO_DOCKER_EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# Get email credentials from the environment.
EMAIL_HOST = os.environ.get('EMAIL_HOST')
EMAIL_HOST_USER = os.environ.get('EMAIL_HOST_USER')
EMAIL_HOST_PASSWORD = os.environ.get('EMAIL_HOST_PASSWORD')
EMAIL_PORT = 587
EMAIL_USE_TLS = True

STATIC_ROOT = os.path.join(PROJECT_DIR, 'static_root')
STATIC_URL = '/static/'

MEDIA_ROOT = os.path.join(VAR_DIR, 'media_root')
MEDIA_URL = '/media/'

# Prefix for admin URL paths, see `ixc_django_docker.urls`
ADMIN_URL = '/admin/'

#
# HTTPS
#

CSRF_COOKIE_SECURE = True  # Require HTTPS for CSRF cookie
SESSION_COOKIE_SECURE = True  # Require HTTPS for session cookie

#
# PERFORMANCE
#

# Enable persistent database connections.
CONN_MAX_AGE = 60  # Default: 0

#
# ERROR REPORTING
#

# Create missing logfile directory.
LOGFILE_DIR = os.path.join(VAR_DIR, 'log')
try:
    os.makedirs(LOGFILE_DIR)
except OSError:
    pass

LOGLEVEL = os.environ.get('LOGLEVEL', 'info').upper()

# Add a root logger and change level for console handler.
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'default': {
            'format': '%(asctime)s '
                      '%(levelname)s '
                      '%(module)s.%(funcName)s:%(lineno)d '
                      '%(message)s',
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'default',
        },
        'logfile': {
            'backupCount': 10,
            'class': 'concurrent_log_handler.ConcurrentRotatingFileHandler',
            'filename': os.path.join(LOGFILE_DIR, '%s.log' % PROJECT_SLUG),
            'formatter': 'default',
            'maxBytes': 20 * 1024 * 1024,  # 20 MiB
        },
        'null': {
            'class': 'logging.NullHandler',
        },
    },
    'loggers': {
        '': {
            'handlers': ['console', 'logfile'],
            'level': LOGLEVEL,  # Default: WARNING
        },
    },
}

# Silence the given loggers.
for logger in os.environ.get('NULL_LOGGERS', '').split():
    if logger:
        LOGGING['loggers'][logger] = {
            'handlers': ['null'],
            'propagate': False,
        }

# Override level for the given loggers.
for level in ('EXCEPTION', 'ERROR', 'WARNING', 'INFO', 'DEBUG'):
    for logger in os.environ.get('%s_LOGGERS' % level, '').split():
        if logger:
            LOGGING['loggers'].setdefault(logger, {})
            LOGGING['loggers'][logger]['level'] = level

ADMINS = (
    ('Admin', 'admin@%s' % SITE_DOMAIN),
)
MANAGERS = ADMINS

# DJANGO ######################################################################

AUTHENTICATION_BACKENDS = (
    'django.contrib.auth.backends.ModelBackend',  # Default
)

DEFAULT_FILE_STORAGE = 'ixc_django_docker.storage.PublicStorage'

DEFAULT_FROM_EMAIL = SERVER_EMAIL = 'noreply@%s' % SITE_DOMAIN

EMAIL_SUBJECT_PREFIX = '[%s] ' % PROJECT_SLUG

# FILE_UPLOAD_PERMISSIONS = 0755  # Default: None

INSTALLED_APPS = (
    # Default.
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    # Extra.
    'django.contrib.admindocs',
    'django.contrib.sitemaps',
)

LANGUAGE_CODE = 'en-au'  # Default: en-us

LOGIN_REDIRECT_URL = '/'  # Default: /accounts/profile/
LOGIN_URL = reverse_lazy('login')  # Default: /accounts/signin/
LOGOUT_URL = reverse_lazy('logout')  # Default: /accounts/signout/

if django.VERSION < (1, 10):
    MIDDLEWARE_CLASSES = (
        # Default.
        'django.contrib.sessions.middleware.SessionMiddleware',
        'django.middleware.common.CommonMiddleware',
        'django.middleware.csrf.CsrfViewMiddleware',
        'django.contrib.auth.middleware.AuthenticationMiddleware',
        'django.contrib.messages.middleware.MessageMiddleware',
        'django.middleware.clickjacking.XFrameOptionsMiddleware',

        # Extra.
        'django.contrib.admindocs.middleware.XViewMiddleware',
    )
    if django.VERSION >= (1, 7):
        MIDDLEWARE_CLASSES += (
            'django.contrib.auth.middleware.SessionAuthenticationMiddleware',
        )
    if django.VERSION >= (1, 8):
        MIDDLEWARE_CLASSES = (
            'django.middleware.security.SecurityMiddleware',
        ) + MIDDLEWARE_CLASSES
else:
    MIDDLEWARE = (
        # Default.
        'django.middleware.security.SecurityMiddleware',
        'django.contrib.sessions.middleware.SessionMiddleware',
        'django.middleware.common.CommonMiddleware',
        'django.middleware.csrf.CsrfViewMiddleware',
        'django.contrib.auth.middleware.AuthenticationMiddleware',
        'django.contrib.messages.middleware.MessageMiddleware',
        'django.middleware.clickjacking.XFrameOptionsMiddleware',
    )

ROOT_URLCONF = 'ixc_django_docker.urls'

# Fix HTTPS redirect behind proxy.
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')

# Avoid session conflicts when running multiple projects on the same domain.
SESSION_COOKIE_NAME = 'sessionid-%s' % PROJECT_SLUG

# Every write to the cache will also be written to the database. Session reads
# only use the database if the data is not already in the cache.
SESSION_ENGINE = 'django.contrib.sessions.backends.cached_db'

STATICFILES_DIRS = (
    os.path.join(PROJECT_DIR, 'static'),
    os.path.join(PROJECT_DIR, 'bower_components'),
)

STATICFILES_FINDERS = (
    # Default.
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
)

import django

TEMPLATES = (
    # Django templates backend.
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [  # Default: empty
            os.path.join(PROJECT_DIR, 'templates'),
        ],
        # 'APP_DIRS': True,  # Must not be set when `loaders` is defined
        'OPTIONS': {
            'context_processors': [
                # Default.
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',

                # Project.
                'ixc_django_docker.context_processors.environment',
            ] + (
                # Extra.
                [
                    'django.core.context_processors.i18n',
                    'django.core.context_processors.media',
                    'django.core.context_processors.static',
                    'django.core.context_processors.tz',
                ] if django.VERSION < (1, 8) else [
                    'django.template.context_processors.i18n',
                    'django.template.context_processors.media',
                    'django.template.context_processors.static',
                    'django.template.context_processors.tz',
                ]
            ),
            'loaders': [
                # Default.
                'django.template.loaders.filesystem.Loader',
                'django.template.loaders.app_directories.Loader',
            ],
        },
    },
    # Jinja2 template backend.
    {
        'BACKEND': 'django.template.backends.jinja2.Jinja2',
        'DIRS': [
            os.path.join(PROJECT_DIR, 'jinja2'),
        ],
        'APP_DIRS': True,
        'OPTIONS': {
            'environment': 'ixc_django_docker.jinja2.environment',
        }
    },
)

TIME_ZONE = 'Australia/Sydney'  # Default: America/Chicago

USE_ETAGS = True  # Default: False
# USE_I18N = False  # Default: True
USE_L10N = True  # Default: False
USE_TZ = True  # Default: False

WSGI_APPLICATION = None

# IXC-DJANGO-DOCKER ###########################################################

RUNTIME_DIRS = STATICFILES_DIRS + (
    MEDIA_ROOT,
    os.path.join(PROJECT_DIR, 'templates'),
    os.path.join(VAR_DIR, 'run'),
)
