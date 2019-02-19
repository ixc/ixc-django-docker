# Django 1.6 doesn't have an `AppConfig.ready()` hook, but installed apps are
# imported. So call our Django 1.6 compatible version of `TracerConfig.ready()`
# from here.

from ixc_django_docker.ddtrace16.apps import TracerConfig

TracerConfig().ready()
