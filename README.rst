===========================================================================
ixc-django-docker: Run Django projects consistently with and without Docker
===========================================================================

A collection of scripts and config files that make it easier to run Django
projects consistently with and without Docker (for Mac/Windows, Cloud, etc.)

It includes:

* Entrypoint, setup, and program wrapper scripts. See ``help.sh``.

* A Django project template with safe default settings and hooks to integrate
  context processors, settings, static files, templates, URLs, etc., from your
  project.

* Supervisord config that runs Gunicorn behind a buffering proxy (Nginx) and
  logs to stderr/stdout.


Django Project Template
=======================

The ``project_template`` directory contains scripts and configurations files
that you copy into the root directory of a new or existing project to quickly
gain features including:

* example settings to create and run a Docker development environment that will
  correspond closely to real Docker-based site deployments. See
  `Run with Docker`_

* a ``go.sh`` script to create a Docker-like development environment in which
  the collected the scripts and configurations can be applied as closely as
  possible to a real Docker environment. See `Run without Docker`_.

* project settings and hooks for context processors, settings, static files,
  templates, etc.

* an ``environment`` context processor that returns settings referenced in
  the ``CONTEXT_PROCESSOR_SETTINGS`` setting.

* ``static`` and ``url`` functions in the Jinja2 environment, that
  correspond with the built in Django template tags of the same names.

To apply the template to an existing project see
`How to dockerize an existing project`_.


Apply and Customise Settings
============================

The ``ixc_django_docker.settings`` package includes many small settings modules
that can be combined as required, which you apply in your project via
configuration conventions and the template project scripts.

The settings modules are loaded using features of
`django-split-settings <https://github.com/sobolevn/django-split-settings>`_.

Think of project settings as a three-level hierarchy:

* **base** settings are included in `ixc-django-docker` for complex and
  commonly-used project features.

* **project** settings are specific to your project, and either add to or
  modify *base* settings.

* **environment** settings are specific to a particular environment in which
  your project runs, such as local development, a staging server, or the final
  production environment. These settings add to or modify *base* and *project*
  settings.

  Note that `ixc-django-docker` also includes some base settings with common
  customisations for different environments.

To configure an `ixc-django-docker` project's settings configure the following
environment variables::

    BASE_SETTINGS

        A space separated list of **base** settings modules to be loaded from
        the ``ixc_django_docker/settings`` directory.

        Default: base.py compressor.py logentries.py storages.py whitenoise.py

    PROJECT_SETTINGS

        A single settings module to be loaded from the project directory.

        Default: ``project_settings.py``

    DOTENV

        The name of the desired runtime environment, used primarily to find and
        load text files that contain further environment variables and arel
        named as ``.env.<DOTENV>``. These environment variable files are loaded
        by ``entrypoint.sh``.

        Default: NONE; ``.env.local`` and ``.env.base`` files are found and
                 loaded in all cases.

    OVERRIDE_SETTINGS

        A single settings module to be loaded from either the base and project
        settings modules directories, if it exists.

        Default: Same as ``DOTENV`` with a ``.py`` extension appended.

All settings modules should be given as file system paths relative to the
installed location of `ixc-django-docker` for **base** settings, or relative
to your project's home directory for all other modules.

Do not use dotted path module names.


Base Settings Modules in ixc-django-docker
------------------------------------------

The base settings modules included in ``ixc-django-docker.settings``, and which
are be applied via ``BASE_SETTINGS``, can provide either feature settings or
settings that are suitable for a particular run-time environment.

Environment settings modules:

* ``develop.py`` - set ``DEBUG`` mode, don't send emails, disable caching,
  relax security restrictions, etc.

* ``test.py`` - install additional test apps, etc.

* ``staging.py`` - don't send emails, enable logging, aggressive caching, etc.

* ``production.py`` - **do** send emails, enable logging, aggressive caching,
    etc.

Feature settings modules (this list is probably incomplete):

* ``base.py`` - a **required** settings module that is the base for all
  subsequent settings modules. Applies default settings needed by all projects,
  often using values from environment variables set for a specific runtime
  environment (or set as default values by `ixc-django-docker` shell scripts).

* ``celery.py`` - use Celery and CeleryBeat for processing scheduled tasks.

* ``celery_email.py`` - use CeleryEmail for out-of-band email messaging.

* ``compressor.py`` - use Compressor to compile and compress static files
  including CSS, Less, SaSS

* ``debug_toolbar.py`` - **for development only** enable ``debug_toolbar`` for
  easier debugging.

* ``extensions.py`` - **for development only** enable `django_extensions
  <https://django-extensions.readthedocs.io/en/latest/>`_ for a richer Django
  dev environment

* ``haystack.py`` - enable the ElasticSearch Haystack backend for search.

* ``logentries.py`` - enable logging to the `LogEntries
  <https://logentries.com/>`_ service and format log messages. Requires the
  ``LOGENTRIES_TOKEN`` environment variable.

* ``master_password.py`` - **for development only** enable the
  ``master_password`` authentication override, to always accept a master
  password set with the ``MASTER_PASSWORD`` environment variable.

* ``nose.py`` - **for development or test environments only** enable and
  configure the Nose unit test runner

* ``post_office.py`` - enable the `Django Post Office
  <https://pypi.python.org/pypi/django-post_office>`_ for monitoring,
  background sending, and templating of email messages.

* ``redis_cache.py`` - enable a read Redis cache. Requires the
  ``REDIS_ADDRESS`` environment variable as processed by ``base.py``.

* ``sentry.py`` - enable Sentry/Raven error reporting. Requires the
  ``SENTRY_DSN`` environment variable.

* ``storages.py`` - enable and configure Amazon S3 as the site's storage
  backend. Requires the ``MEDIA_AWS_ACCESS_KEY_ID``,
  ``MEDIA_AWS_SECRET_ACCESS_KEY``, and (optional)
  ``MEDIA_AWS_STORAGE_BUCKET_NAME`` environment variables.

* ``whitenoise.py`` - enable `IC's improvements
  <https://github.com/ixc/ixc-whitenoise>`_ to `WhiteNoise
  <http://whitenoise.evans.io/>`_ for simplified static file serving.



Settings typically need to address scaling issues
-------------------------------------------------

* Compress CSS/JS offline, so each container in a multi-node configuration has
  immediate access to all compressed assets.

  In-request compression does not work in a multi-node configuration, because
  the container doing the compression may not be the one that receives the
  request for compressed assets.

* Use service host names instead of ``localhost`` for ElasticSearch, Redis, etc.

* Use a service like `LogEntries <https://logentries.com>`__ to store logs, to
  avoid data loss when ephemeral nodes are terminated and as a bonus, make log
  analysis much easier.

* Disable anything in the base settings module that triggers a connection
  attempt to a remote service, which will not be available when building Docker
  images.

  For example, the ``compress`` management command will attempt to connect to
  the configured cache backend.

* Use S3 remote storage for uploaded media. Containers run on ephemeral
  infrastructure that may disappear at any time. In a multi-node configuration,
  all nodes need access to media.

* Use ``whitenoise`` to efficiently serve compressed and forever cacheable
  static files and media.

**TODO:** Use a CDN in front of ``whitenoise`` for static files and media, like
Cloudfront.


About secrets
=============

Secrets should only be stored in ``.env.*`` and ``docker-cloud.*.yml`` files,
which must be encrypted by ``git-secret`` or ``transcrypt``.


Transcrypt (recommended)
------------------------

To enable, set the ``TRANSCRYPT_PASSWORD`` environment variable in
``.env.local`` and ``docker-cloud.*.yml`` files.

* Much simpler in concept and implementation. Bash and OpenSSH are the only
  requirements.

* Needs only a password (no personal or other keys) to decrypt.

* Automated encryption and decryption via git attributes. Easy to view diffs and
  stage individual hunks.

* Committing changes with a git client that does not support git attributes
  makes it surprisingly easy to accidentally commit unencrypted secrets.


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


LogEntries for Log Capture
==========================

Docker containers are often run on ephemeral infrastructure with no persistent
storage for logs. We can send and aggregate container stdout, Python logs, and
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


How to Run an ixc-django-docker Project
=======================================

Run with Docker
---------------

Running a project in a full Docker environment will give a development
environment that is the closest with real production sites, with less need to
install and configure supporting services.

The main drawback of doing this, however, is that it tends to be monumentally
slow.

Run an interactive shell::

    $ docker-compose run --rm --service-ports bash

Start all services::

    $ docker-compose up -d haproxy

View logs for all services::

    $ docker-compose logs -f

Stop all services::

    $ docker-compose stop


Run without Docker
------------------

Running a project in a simulated Docker environment will give a development
envifonment that is not too far from real sites, though you will need to
install and configure supporting services.

Although this environment isn't as close to real sites using Docker directly,
it will run quickly.

To set up (on first time) and run a Docker-like interactive shell::

    $ ./go.sh


^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Requirements when running without Docker
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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
* Transcrypt
* git-secret (not recommended)


macOS
^^^^^

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
