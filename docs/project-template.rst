Wrapped Django project template
===============================

The ``project_template`` directory is an example *wrapped* Django project.

To create a new project from the template:

    $ bash <(curl -Ls https://raw.githubusercontent.com/ixc/ixc-django-docker/master/startproject.sh) PROJECT_NAME

To upgrade an existing ``ixc-django-docker`` project with the currently
installed version of the template:

    $ manage.py update_ixc_django_docker_project_template

Otherwise, see `How to dockerize an existing project`_.


Notable features include:

* ``Dockerfile`` and ``docker-compose.yml`` files for building a Docker image
  and running the project with Docker. See `Run with Docker`_

* A ``go.sh`` script that bootstraps a pre-configured interactive Bash shell for
  running the project without Docker. See `Run without Docker`_.

* Settings to be included by ``ixc_django_docker.settings``.

* URLs to be included by ``ixc_django_docker.urls``.

* A context processor to be included by
  ``ixc_django_docker.context_processors.environment`` and
  ``ixc_django_docker.jinja2.environment``.

* Transparently encrypt ``*.secret*`` files, e.g. credentials in ``.env.*``
  files.

* Example environment specific ``.env`` file.

* Example local override settings module and ``.env`` files.

* Example Docker Cloud stack file.

You should add static files to a ``static`` directory, and templates to a
``templates`` directory. These will override any other Django app static files
and templates.
