from __future__ import absolute_import

import importlib
# import logging
import os
import sys

BASE_SETTINGS_MODULE = os.environ.setdefault('BASE_SETTINGS_MODULE', 'base')
print('# BASE_SETTINGS_MODULE: %s' % BASE_SETTINGS_MODULE)

# Emulate `from {base_settings} import *`.
try:
    base_settings = importlib.import_module(
        'project_settings_%s' % BASE_SETTINGS_MODULE)
except ImportError:
    try:
        base_settings = importlib.import_module(
            'ixc_django_docker.settings.%s' % BASE_SETTINGS_MODULE)
    except ImportError:
        base_settings = importlib.import_module(BASE_SETTINGS_MODULE)
locals().update(base_settings.__dict__)

# Create missing runtime directories.
runtime_dirs = STATICFILES_DIRS + (
    MEDIA_ROOT,
    os.path.join(PROJECT_DIR, 'templates'),
    os.path.join(VAR_DIR, 'logs'),
    # os.path.join(VAR_DIR, 'run'),
)
for dirname in runtime_dirs:
    try:
        os.makedirs(dirname)
    except OSError:
        pass
