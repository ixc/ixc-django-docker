import os

from django.core.servers.basehttp import get_internal_wsgi_application

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "ixc_django_docker.settings")

application = get_internal_wsgi_application()
