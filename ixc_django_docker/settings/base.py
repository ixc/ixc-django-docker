"""
Safe default settings, based on Django 1.8 LTS project template and checklist.
"""

import os
import random
import re
import string

from django.core.urlresolvers import reverse_lazy
from django.utils.text import slugify

PROJECT_DIR = os.path.abspath(os.environ['PROJECT_DIR'])

PROJECT_SLUG = re.sub(r'[^0-9A-Za-z]+', '-', slugify(
    unicode(os.path.basename(PROJECT_DIR)).lower()))

SITE_DOMAIN = os.environ.get('SITE_DOMAIN', '%s.lvh.me' % PROJECT_SLUG)

VAR_DIR = os.path.join(PROJECT_DIR, 'var')

# DJANGO CHECKLIST ############################################################

# See https://docs.djangoproject.com/en/1.8/howto/deployment/checklist/

#
# CRITICAL
#

# Get the secret key from the environment.
SECRET_KEY = os.environ.get('SECRET_KEY')

# Don't show detailed error pages when exceptions are raised.
DEBUG = False

#
# ENVIRONMENT SPECIFIC
#

# Allow connections only on the site domain.
ALLOWED_HOSTS = ('.%s' % SITE_DOMAIN, )

# Use dummy caching, so we don't get confused because a change is not taking
# effect when we expect it to.
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.dummy.DummyCache',
        'KEY_PREFIX': 'default-%s' % PROJECT_SLUG,
    }
}

# Use SQLite, because it has no external dependencies.
DATABASES = {
    'default': {
        'ATOMIC_REQUESTS': True,
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(VAR_DIR, 'db.sqlite3'),
    },
}

EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

EMAIL_HOST = os.environ.get('EMAIL_HOST')
EMAIL_HOST_USER = os.environ.get('EMAIL_HOST_USER')
EMAIL_HOST_PASSWORD = os.environ.get('EMAIL_HOST_PASSWORD')
EMAIL_PORT = 587
EMAIL_USE_TLS = True

STATIC_ROOT = os.path.join(PROJECT_DIR, 'static_root')
STATIC_URL = '/static/'

MEDIA_ROOT = os.path.join(VAR_DIR, 'media_root')
MEDIA_URL = '/media/'

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

# Add a root logger and change level for console handler to `DEBUG`.
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'logfile': {
            'format': (
                '%(asctime)s %(levelname)s (%(module)s.%(funcName)s) '
                '%(message)s'),
        },
    },
    'filters': {
        'require_debug_true': {
            '()': 'django.utils.log.RequireDebugTrue',
        },
    },
    'handlers': {
        'console': {
            'level': 'DEBUG',
            'filters': ['require_debug_true'],
            'class': 'logging.StreamHandler',
        },
    },
    'loggers': {
        '': {
            'handlers': ['console'],
        },
    },
}

ADMINS = (
    ('Admin', 'admin@%s' % SITE_DOMAIN),
)
MANAGERS = ADMINS

# DJANGO ######################################################################

AUTHENTICATION_BACKENDS = (
    'django.contrib.auth.backends.ModelBackend',  # Default
)

# Enable cross-subdomain cookies, only if `SITE_DOMAIN` is not a TLD.
if '.' in SITE_DOMAIN:
    CSRF_COOKIE_DOMAIN = LANGUAGE_COOKIE_DOMAIN = SESSION_COOKIE_DOMAIN = \
        '.%s' % SITE_DOMAIN

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

LOGIN_REDIRECT_URL = '/'  # Default: '/accounts/profile/'
LOGIN_URL = reverse_lazy('login')  # Default: '/accounts/signin/'
LOGOUT_URL = reverse_lazy('logout')  # Default: '/accounts/signout/'

MIDDLEWARE_CLASSES = (
    # Default.
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.auth.middleware.SessionAuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'django.middleware.security.SecurityMiddleware',

    # Extra.
    'django.contrib.admindocs.middleware.XViewMiddleware',
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

                # Extra.
                'django.core.context_processors.i18n',
                'django.core.context_processors.media',
                'django.core.context_processors.static',
                'django.core.context_processors.tz',

                # Project.
                'ixc_django_docker.context_processors.environment',
            ],
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

WSGI_APPLICATION = 'ixc_django_docker.wsgi.application'
