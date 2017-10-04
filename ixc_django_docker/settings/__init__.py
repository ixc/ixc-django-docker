from __future__ import absolute_import

# Settings import chain:
#     project_settings_local
#     project_settings
#     ixc_django_docker.settings.calculated

# Calculated settings import chain:
#     project_settings_{base_settings_module}
#     ixc_django_docker.settings.{base_settings_module}
#     {base_settings_module}
#     ixc_django_docker.settings.base

try:
    try:
        # Local project settings.
        from project_settings_local import *
    except ImportError, err:
        # Re-raise import error if it's inside, not just, the top-level module
        if not unicode(err).endswith('project_settings_local'):
            raise
        # Project settings.
        from project_settings import *
except ImportError, err:
    # Re-raise import error if it's inside, not just, the top-level module
    if not unicode(err).endswith('project_settings'):
        raise
    # Calculated settings.
    from .calculated import *
