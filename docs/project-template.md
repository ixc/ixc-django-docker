Wrapped Django project template
===============================

The `project_template` directory is an example *wrapped* Django project.

It includes:

* `Dockerfile` and `docker-compose.yml` files for building a Docker image and
  [running the project with Docker](run-with-docker.md).

* A `go.sh` script that bootstraps a pre-configured interactive Bash shell for
  [running the project without Docker](run-without-docker.md).

* `base.py` and example override `local.sample.py` settings modules to be
  included by `ixc_django_docker.settings`.

* URLs to be included by `ixc_django_docker.urls`.

* A context processor to be included by both
  `ixc_django_docker.context_processors.environment` and
  `ixc_django_docker.jinja2.environment`.

* Transparently encrypt `*.secret*` files. E.g. credentials in `.env.*` and
  `docker-cloud.*.secret.yml` files.

* Example environment specific `.env.DOTENV.sample` file.

* Example override `.env.local.sample` file.

* Example `docker-cloud.yml` stack file.

* Empty `static` and `templates` directories. Any files in these two directories
  will override any other Django static files and templates.
