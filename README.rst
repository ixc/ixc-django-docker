=========================================================
Run Django projects consistently, with and without Docker
=========================================================

This is an attempt at:

* Making it easier to run Django projects consistently with and without Docker
  (for Mac/Windows, Cloud, etc.), in development and production environments.

* Solving issues relating to horizontal scaling and ephemeral infrastructure,
  where you have no persistent local storage and requests are handled by
  multiple servers in a load balanced configuration.

* Providing a migration path towards Docker for legacy projects.

* Getting new projects up and running quickly with a consistent and familiar
  base to build from.

It includes:

* A reference Django project that *wraps* another Django project to provide
  sensible default settings plus many optional but commonly needed features.

* A *wrapped* Django project template that you can use as a starting point for
  new projects or when Dockerizing a legacy project.


Django project wrapper
======================

The ``ixc_django_docker`` Python package is a Django project (settings, URLs,
etc.) that wraps another project by including additional settings, static files,
templates, URLs, etc., from the other project.

This makes it easy to enable optional but commonly needed features and evolve
our shared understanding of current best practices over time.

It includes:

* A ``manage.py`` script that you can execute from any directory when your
  project environment is active.

* Safe and secure default settings with integration hooks for your project.

* Optional composable settings modules that solve issues relating to horizontal
  scaling and ephemeral infrastructure or enable commonly needed features.

* Override settings for develop, staging, test, and production environments.

* Optional integrations with LogEntries, New Relic and Sentry.

* Public and private storage classes that can be configured as local or remote
  (S3) via the ``ENABLE_S3_STORAGE`` setting, or use unique (forever-cacheable)
  names via the ``ENABLE_UNIQUE_STORAGE`` setting

* A ``get_local_file_path()`` context manager, for when local file system access
  is required (e.g. transcoding an audio file in a subprocess).

* An ``environment`` context processor that wraps a project context processor
  and includes any settings specified in ``CONTEXT_PROCESSOR_SETTINGS``.

* An ``environment`` function that wraps the ``environment`` context processor
  and adds ``static`` and ``url`` functions, returned as a Jinja2
  ``Environment`` object, so you can more easily use both Django and Jinja2
  template engines.

* Automatically install Bower components, Node modules and Python packages, or
  apply Django migrations, when required.

* Automatically create required runtime directories at startup.

* Remote debugging with PyCharm. For example, when your application is running
  in a container or on a remote server.

* Show a coverage report after you run tests.


Wrapped Django project template
===============================

The ``project_template`` directory is an example *wrapped* Django project.

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

To create a new project from the template:

    $ bash <(curl -Ls https://raw.githubusercontent.com/ixc/ixc-django-docker/master/startproject.sh) PROJECT_NAME

To upgrade an existing ``ixc-django-docker`` project with the currently
installed version of the template:

    $ manage.py update_ixc_django_docker_project_template

Otherwise, see `How to dockerize an existing project`_.


Composable settings
===================

The ``ixc_django_docker.settings`` package includes many composable settings
modules that can be combined as required.

The settings modules are included and combined via
`django-split-settings <https://github.com/sobolevn/django-split-settings>`_.

Think of settings as a hierarchy:

* **base** settings are included from ``ixc_django_docker.settings`` for
  critical and optional but commonly needed configuration.

* **project** settings are included from ``ixcproject.settings`` for project
  specific configuration, and they override *base* settings.

* **override** settings are included from ``ixc_django_docker.settings`` *and*
  ``ixcproject.settings`` for environment specific configuration, and they
  override both *base* and *project* settings.

* **dotenv** environment variables are sourced from ``.env.base``,
  ``.env.DOTENV.secret`` and ``.env.local`` files, and they are available to
  Bash scripts, running processes and *base*, *project* and *override* settings.

To configure an ``ixc-django-docker`` project, specify the following environment
variables::

    BASE_SETTINGS

        A space separated list of *base* settings modules to be included from
        ``ixc_django_docker.settings``.

        Default: ``base.py compressor.py logentries.py storages.py whitenoise.py``  # Just enough to solve horizontal scaling and ephemeral infrastructure issues

    PROJECT_SETTINGS

        A single settings module to be included from ``ixcproject.settings``.

        Default: ``base.py``

    OVERRIDE_SETTINGS

        A single settings module to be included from
        ``ixc_django_docker.settings`` *and* ``ixcproject.settings``.

        Default: ``$DOTENV.py``

    DOTENV

        The ``.env.$DOTENV.secret`` file to be sourced by ``entrypoint.sh``.

        Default: Undefined

**WARNING:** All settings modules should be specified as file system paths
relative to the settings package they are to be included from, not dotted path
module names.


How to specify environment variables
------------------------------------

With Docker Compose or ``go.sh``, you *must* create a ``.env.local`` file which
specifies at least ``DOTENV`` and ``GPG_PASSPHRASE`` or ``TRANSCRYPT_PASSWORD``.

With Docker Cloud, you must specify these in your stack file for every
``ixc-django-docker`` service.

All other environment variables can then be specified in ``.env.base`` and
``.env.$DOTENV.secret`` files.

**NOTE:** ``.env.local`` is sourced *twice*. Once to obtain the ``DOTENV`` and
``GPG_PASSPHRASE`` or ``TRANSCRYPT_PASSWORD`` variables that are required to
decrypt ``.env.$DOTENV.secret``, then again to override any conflicting
environment variables.


Bundled base settings
---------------------

* ``base.py`` - Safe default settings, based on Django 1.8 LTS project template
  and checklist.

  **NOTE:** This settings module is *required*.

  **TODO:** Should we include it automatically, since it is required? Perhaps we
  need a ``base18.py`` and ``base111.py``?

* ``celery.py`` - Use `Celery <http://docs.celeryproject.org/en/latest/index.html>`_
  and `Celery Beat <http://docs.celeryproject.org/en/latest/userguide/periodic-tasks.html>`_
  for asynchronous and scheduled task processing.

* ``celery_email.py`` - Use `django-celery-email <https://github.com/pmclanahan/django-celery-email>`_
  for asynchronous email delivery via Celery.

* ``compressor.py`` - Use `django-compressor <https://github.com/django-compressor/django-compressor>`_
  to compile and compress CSS, JavaScript, Less, Sass, etc.

* ``debug_toolbar.py`` - Enable `django-debug-toolbar <https://github.com/jazzband/django-debug-toolbar>`_.

* ``extensions.py`` - Use `django-extensions <https://django-extensions.readthedocs.io/en/latest/>`_
  for convenience and debugging (``manage.py shell_plus``, Werkzeug, etc.)

* ``haystack.py`` - Use `django-haystack <https://github.com/django-haystack/django-haystack>`_
  with `ElasticSearch <https://www.elastic.co/>`_ backend for search.

* ``logentries.py`` - Enable `LogEntries <https://logentries.com/>`_ integration
  for persistent log storage and aggregation.

  **NOTE:** Requires a LogEntries account and the ``LOGENTRIES_TOKEN``
  environment variable.

* ``master_password.py`` - Use `django-master-password <https://github.com/ixc/django-master-password>`_
  to accept a master password for any account.

  **NOTE:** Requires the ``MASTER_PASSWORD`` environment variable.

  **WARNING:** This is not recommended for production environments. When
  ``DEBUG=False``, the master password *must* be **strong** and **encrypted**
  (see ``manage.py make_password``).

* ``nose.py`` - Use `django-nose <https://github.com/django-nose/django-nose>`_
  with `nose-exclude <https://github.com/kgrandis/nose-exclude>`_ and
  `nose-progressive <https://github.com/erikrose/nose-progressive>`_ when
  running tests.

* ``post_office.py`` - Use `django-post-office
  <https://github.com/ui/django-post_office>`_ for asynchronous email delivery
  and logging.

  **TODO:** Remove this, now that we use ``django-celery-email``?

* ``redis_cache.py`` - Use `python-redis-lock <https://github.com/ionelmc/python-redis-lock>`_
  as the default cache backend, for performance and convenience.

  **NOTE:** Requires a Redis server and the ``REDIS_ADDRESS`` (``HOST:PORT``)
  environment variable.

* ``sentry.py`` - Use `Sentry <https://sentry.io/>`_ for server error
  aggregation and alerts.

  **NOTE:** Requires a Sentry account or private instance and the ``SENTRY_DSN``
  environment variable.

* ``storages.py`` - Use `django-storages <https://github.com/jschneier/django-storages>`_
  to enable remote storage on AWS S3.

  **NOTE:** Requires an AWS S3 bucket and IAM user with appropriate permissions,
  and the ``MEDIA_AWS_ACCESS_KEY_ID``, ``MEDIA_AWS_SECRET_ACCESS_KEY``
  environment variables.

  **NOTE:** Requires the ``MEDIA_AWS_STORAGE_BUCKET_NAME`` environment variable,
  if your bucket is not named the same as your project slug.

* ``whitenoise.py`` - Use `whitenoise <https://github.com/evansd/whitenoise>`_
  and `ixc-whitenoise <https://github.com/ixc/ixc-whitenoise>`_ to serve static
  files *and* media.


Bundled override settings
-------------------------

* ``develop.py`` - Enable ``DEBUG`` mode, relax security, etc.

* ``test.py`` - Enable ``DEBUG`` mode, relax security, enable caching, configure
  test database, etc.

* ``staging.py`` - Reconfigure logging, enable caching, etc.

* ``production.py`` - Reconfigure logging, enable caching, reconfigure email
  backend (actually send emails), etc.


Encrypted secrets
=================

Secrets should only be stored in ``.env.*.secret`` and ``docker-cloud.*.yml``
files, which must be encrypted by ``transcrypt`` or ``git-secret``.


Transcrypt (recommended)
------------------------

To enable, set the ``TRANSCRYPT_PASSWORD`` environment variable in
``.env.local`` and ``docker-cloud.*.yml`` files.

* Much simpler than ``git-secret`` in concept and implementation. Bash and
  OpenSSH are the only requirements.

* Needs only one password (no personal or other keys) to decrypt.

* Automated encryption and decryption via git attribute filters.

**WARNING:** Committing changes with a git client that does not support git
attribute filters makes it easy to accidentally commit unencrypted secrets.


Git-Secret (not recommended)
----------------------------

To enable, set the ``GPG_PASSPHRASE`` environment variable in ``.env.local`` and
``docker-cloud.*.yml`` files.

* Uses GPG for encryption, which can be painful, especially when running via
  ``go.sh``, as there are several version compatibility issues.

* Security model allows individual developers to have access granted or revoked
  by their personal keys. However, in an attempt to keep things simple, we
  ignore this feature and commit a single key directly to the repository,
  protected by a strong random passphrase.

* Stores encrypted files with a ``.secret`` file extension, and ignores the
  unencrypted version to ensure unencrypted secrets are never committed.

* Manual process to encrypt and decrypt files. Difficult to diff and stage
  individual hunks.

**TODO:** Remove this, if we don't recommend it?


LogEntries
==========

Docker containers are often run on ephemeral infrastructure with no persistent
storage for logs. You can send and aggregate container stdout, Python logs, and
file based logs to LogEntries in realtime.

1. Create a new log set named `{PROJECT_NAME}.{DOTENV}`.

2. Create manual (token TCP) logs named `docker-logentries`, `docker-logspout`
   and `python` in that log set.

3. Replace `{DOCKER_LOGENTRIES_TOKEN}` and `{DOCKER_LOGSPOUT_TOKEN}` in your
   compose or stack file, and `{PYTHON_TOKEN}` in your dotenv file, with the
   tokens created above.

4. Copy your account key to `LOGENTRIES_ACCOUNT_KEY` in your dotenv file. See:
   https://docs.logentries.com/v1.0/docs/accountkey/

5. Add `logentries.py` to `BASE_SETTINGS` in your `.env.base` file.


Common horizontal scaling and ephemeral infrastructure issues and solutions
===========================================================================

These are the critical issues that can arise when running a Django project with
Docker on ephemeral infrastructure, that ``ixc-django-docker`` aims to solve:

* Compress CSS, JavaScript, Less, Sass, etc. offline, so each container in a
  multi-node configuration has immediate access to all compressed assets.

  In-request compression does not work in a multi-node configuration, because
  the container doing the compression may not be the one that receives the
  request for compressed assets.

* Use host names instead of ``localhost`` for services, e.g. ElasticSearch,
  PostgreSQL, Redis, etc.

* Use a service like `LogEntries <https://logentries.com>`__ to avoid data loss
  when ephemeral nodes are terminated. As a bonus, aggregators make log analysis
  much easier.

* Disable anything in the base settings module that triggers a connection
  attempt to a remote service, which will not be available when building Docker
  images.

  For example, ``manage.py compress`` will attempt to connect to the configured
  cache backend.

* Use AWS S3 remote storage for uploaded media. Containers run on ephemeral
  nodes that may disappear at any time. In a multi-node configuration, all nodes
  need access to media.

* Use ``whitenoise`` to efficiently serve compressed and uniquely named static
  files and media that can be cached forever.

* Secret management. You don't want to store unencrypted secrets in a Docker
  image or Git repository.

**TODO:** Use a CDN (e.g. Cloudfront) in front of ``whitenoise``.

**TODO:** Move this section to the top of this document?


How to run with Docker
======================

Running a project with Docker environment will run in an environment that is
almost identical to production, with no need to manage service dependencies.

The main drawback is that it can be significantly slower on macOS due to
performance issues with ``osxfs`` shared volumes. See:
https://forums.docker.com/t/file-access-in-mounted-volumes-extremely-slow-cpu-bound/8076/1

Run an interactive shell::

    $ docker-compose run --rm --service-ports bash

Start all services::

    $ docker-compose up -d haproxy

View logs for all services::

    $ docker-compose logs -f

Stop all services::

    $ docker-compose stop


How to run without Docker
=========================

Running a project via ``go.sh`` configures an interactive shell in such a way
that all our shell scripts and project configuration still works as it would
under Docker.

A project run this way will generally perform much quicker than with Docker, but
you will need to manage service dependencies manually.

However, you can still run those service dependencies via Docker, and as long as
they don't use an ``osxfs`` shared volume, performance should be acceptable.

Start services::

    $ docker-compose up -d elasticsearch postgres redis

Or:

    $ brew services start elasticsearch
    $ brew services start postgres
    $ brew services start redis

Run an interactive shell::

    $ ./go.sh

Run individual processes::

    $ celery.sh
    $ celerybeat.sh
    $ celeryflower.sh
    $ runserver.sh

Stop services::

    $ docker-compose stop

Or:

    $ brew services stop elasticsearch
    $ brew services stop postgres
    $ brew services stop redis


System requirements when running without Docker
===============================================

* md5sum
* Nginx
* NPM
* Pipe Viewer
* PostgreSQL
* Python 2.7
* Redis
* Yarn

Optional:

* Elasticsearch 2.x (5.x is not compatible with ``django-haystack``)
* Git-Secret (not recommended)
* Transcrypt


macOS
-----

Install Xcode command line tools::

    $ xcode-select --install

Install `Homebrew <http://brew.sh/>`__::

    $ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

Install `Postgres.app <http://postgresapp.com/>`__.

Install required system packages::

    $ brew install md5sha1sum nginx npm pv python redis yarn

Start Redis::

    $ brew services start redis

Install optional system packages::

    $ brew install elasticsearch@2.4
    $ brew link elasticsearch@2.4 --force
    $ brew install git-secret
    $ brew install transcrypt

Start Elasticsearch::

    $ brew services start elasticsearch


How to run a remote debug server with `pydevd` (e.g. PyCharm)
=============================================================

* Add a `Python Remote Debug` run configuration to PyCharm with the following
  options:

  * Name: `pydevd`
  * Local host name: `localhost`
  * Port: `5678`

* Select the `pydevd` configuration and click the `Debug` icon (`^D`) to start
  the debug server.

* Run the project from your terminal via Docker or `go.sh`.

* Execute your command with remote debugging enabled:

    $ pydevd.sh runserver.sh

You can reconfigure the default host and port for the remote debug server with
the follow environment variables:

    PYDEVD_HOST=localhost
    PYDEVD_PORT=5678

**NOTE:** When running via Docker you will need to specify your LAN IP address
as `PYENVD_HOST` to establish a connection from the container to PyCharm.


How to dockerize an existing project
====================================

* Rename ``requirements.txt`` to ``requirements.in``.

* Add to, or update all files in, your project directory with changes from the
  corresponding files in the ``project_template`` directory.

* Install ``pip-tools``::

    $ pip install pip-tools

* Run ``pip-compile -v``, resolving any conflicts that may arise.

* Make ``go.sh`` executable::

    $ chmod 755 go.sh

* Delete ``manage.py`` from your project. This is now installed into your
  virtualenv bin directory by ``ixc-django-docker``.

* Add a production database dump named ``initial_data.sql`` to your project
  directory.

  This allows us to avoid running migrations from scratch, which often does not
  work with older projects, and saves us time even when migrations do work.

* Use the AWS CLI to sync the production media directory to a new S3 bucket:

    $ pip install awscli
    $ AWS_ACCESS_KEY_ID='' AWS_SECRET_ACCESS_KEY='' AWS_DEFAULT_REGION='us-west-2' aws s3 sync {path/to/media} s3://{bucket-name}/media/ > aws-s3-sync.log 2>&1 & tail -f aws-s3-sync.log

* Update project settings. See [About settings modules], above.

* Add `.env.{FOO}` and `docker-cloud.{FOO}.yml` for each environment. These may
  contain secrets, and must not be committed to the repository unencrypted. See
  [About secrets], above.
