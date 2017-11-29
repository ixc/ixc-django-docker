"""
Use ``django-split-settings`` to combine settings modules from
``ixc-django-docker`` and the project directory.

Define the following environment variables to configure:

    BASE_SETTINGS_MODULES
        Relative to the ``ixc_django_docker/settings`` directory.
        Default: ``base.py calculated.py``

    PROJECT_SETTINGS_MODULES
        Relative to the project directory.
        Default ``project_settings.py project_settings_local.py``

Separate modules with a space.
"""

import os

from split_settings.tools import include, optional

# Get project directory from environment. This MUST already be defined.
PROJECT_DIR = os.environ['PROJECT_DIR']

# Get base settings modules from environment.
BASE_SETTINGS_MODULES = os.environ.get(
    'BASE_SETTINGS_MODULES', ' '.join([
        'base.py',
        # 'celery.py',
        'compressor.py',
        # 'extensions.py',
        'logentries.py',
        'storages.py',
        'whitenoise.py',
    ])).split()

# Get project settings modules from environment.
PROJECT_SETTINGS_MODULES = os.environ.get(
    'PROJECT_SETTINGS_MODULES', ' '.join([
        'project_settings.py',
        'project_settings_local.py',
    ])).split()

# Base settings modules, relative to this file.
SETTINGS_MODULES = BASE_SETTINGS_MODULES[:]

# Project settings modules, relative to `PROJECT_DIR`.
SETTINGS_MODULES.extend([
    optional(os.path.join(PROJECT_DIR, s)) for s in PROJECT_SETTINGS_MODULES
])

# Tell users where settings are being loaded from.
print('BASE_SETTINGS_MODULES:\n  %s' % '\n  '.join(BASE_SETTINGS_MODULES))
print('PROJECT_SETTINGS_MODULES:\n  %s' % '\n  '.join(PROJECT_SETTINGS_MODULES))

# Combine all settings modules.
include(*SETTINGS_MODULES)

# Create missing runtime directories.
for dirname in getattr(locals(), 'RUNTIME_DIRS', ()):
    try:
        os.makedirs(dirname)
    except OSError:
        pass
