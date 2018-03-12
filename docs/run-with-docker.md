Run with Docker
===============

With [Docker][1] you can run a project in an environment that is almost
identical to production.

There is also no need to manage service dependencies, making it easier to get a
project up and running locally.

Unfortunately, Docker for Mac has some [performance issues][2] with `osxfs`
shared volumes, so most developers prefer to [run without Docker][3].

[1]: https://www.docker.com/
[2]: https://forums.docker.com/t/file-access-in-mounted-volumes-extremely-slow-cpu-bound/8076/1
[3]: run-without-docker.md


Quick links
===========

* [Download Docker Community Edition](https://www.docker.com/community-edition#/download)


Getting started
===============

Build an image from `Dockerfile`:

    $ docker-compose build --pull

**NOTE:** You will need to rebuild to pull in updates from the latest
`buildpack-deps:xenial` base image and whenever you modify `Dockerfile`, but
you *don't* need to rebuild when making changes to your project code.

Open an interactive shell:

    $ docker-compose run --rm --service-ports bash

**NOTE:** `--rm` removes the container on exit. `--service-ports` binds
`ports` defined in the `bash` service to the host.

Manually start individual services from the interactive shell:

    (PROJECT_NAME)# celery.sh
    (PROJECT_NAME)# celerybeat.sh
    (PROJECT_NAME)# celeryflower.sh
    (PROJECT_NAME)# manage.py [COMMAND [ARGS]]
    (PROJECT_NAME)# migrate.sh
    (PROJECT_NAME)# pydevd.sh <COMMAND>
    (PROJECT_NAME)# runserver.sh [ARGS]
    (PROJECT_NAME)# runtests.sh [ARGS]

**NOTE:** These are just the most commonly used [commands](commands.md).

When you're done, exit the interactive shell and stop all services:

    $ docker-compose stop


Docker cheat sheet
==================

If you don't need an interactive shell, start all services in the background:

    $ docker-compose up -d

**NOTE:** This environment will be closer to production because services will
be accessed via `haproxy`, and Django will run behind `nginx` via `gunicorn`.

View logs for all background services:

    $ docker-compose logs -f

Open an interactive shell for a running service based on `ixc-django-docker`:

    $ docker-compose exec celery entrypoint.sh

Open an interactive shell for a running service based on Alpine Linux:

    $ docker-compose exec postgres ash
