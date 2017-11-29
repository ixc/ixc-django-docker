import os

from split_settings.tools import include, optional

# Get project directory from environment. This MUST already be defined.
PROJECT_DIR = os.environ['PROJECT_DIR']

# Get base settings.
BASE_SETTINGS = os.environ.get(
    'BASE_SETTINGS', ' '.join([
        'base.py',
        # 'celery.py',
        # 'celery_email.py',
        'compressor.py',
        # 'extensions.py',
        # 'haystack.py',
        'logentries.py',
        # 'master_password.py',
        # 'nose.py',
        # 'post_office.py',
        # 'redis_cache.py',
        # 'sentry.py',
        'storages.py',
        'whitenoise.py',
    ])).split()

# Get project settings.
PROJECT_SETTINGS = [os.path.join(
    PROJECT_DIR, os.environ.get('PROJECT_SETTINGS') or 'project_settings.py',
)]
PROJECT_SETTINGS_DIR = os.path.dirname(PROJECT_SETTINGS[0])

# Get override settings.
# Tell users where base and project settings are coming from.
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

print('BASE_SETTINGS:\n  %s' % '\n  '.join(BASE_SETTINGS))
print('PROJECT_SETTINGS:\n  %s' % '\n  '.join(
    os.path.relpath(s, PROJECT_DIR) for s in PROJECT_SETTINGS))

# Include base and project settings modules.
include(*BASE_SETTINGS)
include(*PROJECT_SETTINGS)

# Create missing runtime directories.
for dirname in getattr(locals(), 'RUNTIME_DIRS', ()):
    try:
        os.makedirs(dirname)
    except OSError:
        pass
