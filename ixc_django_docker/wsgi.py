import os

from django.core.wsgi import get_wsgi_application

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "ixc_django_docker.settings")

application = get_wsgi_application()
