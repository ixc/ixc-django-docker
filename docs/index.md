Run Django projects consistently with (and without) Docker
==========================================================

This project aims to:

* Make it easier to run Django projects consistently with and without Docker
  (for Mac/Windows, Cloud, etc.), in development and production environments.

* Solve issues relating to horizontal scaling and ephemeral infrastructure,
  where you have no persistent local storage and requests are handled by
  multiple servers in a load balanced configuration.

* Provide a migration path towards Docker for legacy projects.

* Get new projects up and running quickly with a consistent and familiar base
  to build from.

It includes:

* A [Django project wrapper](project-wrapper.md) that provides sensible default
  settings plus many optional but commonly needed features.

* A [wrapped Django project template](project-template.md) that you can use as
  a starting point for new projects or when dockerizing an existing project.

* [Composable settings](composable-settings.md) modules with environment
  specific overrides and encrypted secrets. Use as many or as few as you need.

* [Automation and configuration by convention](terminal-commands.md) via shell
  script wrappers and config templates for commonly needed programs and tasks.

See the [rationale](rationale.md) docs for more on why this project exists and
the problems it solves.


Quick links
===========

* [Run with Docker](run-with-docker.md)
* [Run without Docker](run-without-docker.md)
* [Dockerize an existing project](how-to-dockerize.md)
* [Enable remote debugging with PyCharm](how-to-pycharm-remote-debug.md)


Getting started
===============

Create or update a project from the template:

    $ bash <(curl -fLs https://raw.githubusercontent.com/ixc/ixc-django-docker/master/startproject.sh) PROJECT_DIR

Create a `.env.local` file from the sample and set at least the `DOTENV` and
`TRANSCRYPT_PASSWORD` environment variables:

    $ cp .env.local.sample .env.local
    $ vi .env.local

Open an interactive shell with Docker (*or* without, via `go.sh`):

    $ docker-compose run --rm --service-ports bash
    $ ./go.sh

Here is a list of frequently used commands you might want to run:

    $ celery.sh
    $ celerybeat.sh
    $ celeryflower.sh
    $ gunicorn.sh
    $ manage.py [COMMAND [ARGS]]
    $ migrate.sh
    $ nginx.sh
    $ pydevd.sh <COMMAND>
    $ runserver.sh [ARGS]
    $ runtests.sh [ARGS]
    $ supervisor.sh [OPTIONS] [ACTION [ARGS]]
