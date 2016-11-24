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
    except ImportError:
        # Project settings.
        from project_settings import *
except ImportError:
    # Calculated settings.
    from .calculated import *
