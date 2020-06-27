import os

from django.core.exceptions import ImproperlyConfigured
from split_settings.tools import include, optional


def _(module, from_dir):
    relpath = os.path.relpath(
        os.path.abspath(module), os.path.abspath(from_dir))
    if not os.path.exists(module):
        return '%s (NOT FOUND)' % relpath
    return relpath


# Get project directory from environment. This MUST already be defined.
PROJECT_DIR = os.environ['PROJECT_DIR']

# Base settings.
BASE_SETTINGS = os.environ.get(
    'BASE_SETTINGS', ' '.join([
        'base.py',
        # 'celery.py',
        # 'celery_email.py',
        # 'compressor.py',
        # 'extensions.py',
        # 'haystack.py',
        # 'logentries.py',
        # 'master_password.py',
        # 'nose.py',
        # 'post_office.py',
        # 'redis_cache.py',
        # 'sentry.py',
        'storages.py',
        'whitenoise.py',
    ])).split()

# Project settings.
checked = []
for filename in (
    os.environ.get('PROJECT_SETTINGS'),
    'djangosite/settings/base.py',
    'project_settings.py',
):
    if filename:
        checked.append("'%s'" % filename)
        PROJECT_SETTINGS = os.path.join(PROJECT_DIR, filename)
        if os.path.exists(PROJECT_SETTINGS):
            break
else:
    raise ImproperlyConfigured(
        'No project settings found. Checked: ' + ', '.join(checked)
    )
PROJECT_SETTINGS_DIR = os.path.dirname(PROJECT_SETTINGS)
PROJECT_SETTINGS = [PROJECT_SETTINGS]  # Convert to list

# Override settings.
OVERRIDE_SETTINGS = os.environ.get('OVERRIDE_SETTINGS')
if not OVERRIDE_SETTINGS and 'DOTENV' in os.environ:
    OVERRIDE_SETTINGS = '%s.py' % os.environ['DOTENV']
if OVERRIDE_SETTINGS:
    BASE_SETTINGS.append(optional(OVERRIDE_SETTINGS))
    PROJECT_SETTINGS.append(
        optional(os.path.join(PROJECT_SETTINGS_DIR, OVERRIDE_SETTINGS)))

# Local settings.
PROJECT_SETTINGS.append(
    optional(os.path.join(PROJECT_SETTINGS_DIR, 'local.py')))

# Tell users where settings are coming from.
if os.environ.get('SHOW_SETTINGS', '').lower() in ('1', 't', 'true', 'y', 'yes'):
    print('BASE_SETTINGS (%s):\n  %s' % (
        os.path.dirname(__file__),
        '\n  '.join(
            _(os.path.join(os.path.dirname(__file__), s), os.path.dirname(__file__))
            for s in BASE_SETTINGS),
    ))
    print('PROJECT_SETTINGS (%s):\n  %s' % (
        PROJECT_DIR,
        '\n  '.join(
            _(os.path.join(PROJECT_DIR, s), PROJECT_DIR) for s in PROJECT_SETTINGS),
    ))
else:
    print(
        'Not showing actual base and project settings. Set `SHOW_SETTINGS=1` '
        'to change.')

# Include base and project settings modules.
include(*BASE_SETTINGS)
include(*PROJECT_SETTINGS)

# Create missing runtime directories.
for dirname in RUNTIME_DIRS:
    try:
        os.makedirs(dirname)
    except OSError:
        pass

# De-dupe installed apps.
_seen = set()
INSTALLED_APPS = [
    app for app in INSTALLED_APPS if app not in _seen and not _seen.add(app)
]
