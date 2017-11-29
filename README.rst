Overview
--------

A collection of scripts and config files that make it easier to run Django
projects consistently with and without Docker (for Mac/Windows, Cloud, etc.)

It includes:

* Entrypoint, setup, and program wrapper scripts. See ``help.sh``.

* A Django project with safe default settings and hooks to integrate context
  processors, settings, static files, templates, URLs, etc., from your
  project.

* Supervisord config that runs Gunicorn behind a buffering proxy (Nginx) and
  logs to stderr/stdout.


About the included Django project
---------------------------------

* Adds an ``environment`` context processor that returns settings referenced in
  the ``CONTEXT_PROCESSOR_SETTINGS`` setting.

* Adds ``static`` and ``url`` functions to the Jinja2 environment, that
  correspond with the built in Django template tags of the same names.

* Has project hooks for context processors, settings, static files, templates,
  etc.


About settings modules
----------------------

The ``ixc_django_docker.settings`` package includes many small settings modules
that can be combined as required with ``django-split-settings``.

Define the following environment variables to configure::

    BASE_SETTINGS

        A space separated list of settings modules to be loaded from the
        ``ixc_django_docker/settings`` directory.

        Default: base.py compressor.py logentries.py storages.py whitenoise.py

    PROJECT_SETTINGS

        A single settings module to be loaded from the project directory.

        Default: ``project_settings.py``

    OVERRIDE_SETTINGS

        A single settings module to be loaded from both the base and project
        settings modules directories, if it exists.

        Default: Same as ``DOTENV`` with a ``.py`` extension appended.

All settings modules should be given as relative file system paths, not dotted
path module names.

Separate base settings modules with a space. Generally, break down settings into
two types of module:

* Enable a specific app or feature, e.g. ``compressor``, ``haystack``,
  ``logentries``, etc.

* Reconfigure settings appropriately for a specific environment, for example:

  * ``develop`` - don't send emails, disable caching, relax security
    restrictions, etc.

  * ``production`` - do send emails, enable aggressive caching, etc.

  * ``test`` - install additional test apps, etc.


Settings typically need to address these scaling issues
-------------------------------------------------------

* Compress CSS/JS offline, so each container in a multi-node configuration has
  immediate access to all compressed assets.

  In-request compression does not work in a multi-node configuration, because
  the container doing the compression may not be the one that receives the
  request for compressed assets.

* Use service host names instead of ``localhost`` for ElasticSearch, Redis, etc.

* Use a service like [LogEntries](https://logentries.com) to store logs, to
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
-------------

Secrets should only be stored in ``.env.*`` and ``docker-cloud.*.yml`` files,
which must be encrypted by ``git-secret`` or ``transcrypt``.


## Git-Secret (not recommended)

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


## Transcrypt (recommended)

To enable, set the ``TRANSCRYPT_PASSWORD`` environment variable in
``.env.local`` and ``docker-cloud.*.yml`` files.

* Much simpler in concept and implementation. Bash and OpenSSH are the only
  requirements.

* Needs only a password (no personal or other keys) to decrypt.

* Automated encryption and decryption via git attributes. Easy to view diffs and
  stage individual hunks.

* Committing changes with a git client that does not support git attributes
  makes it surprisingly easy to accidentally commit unencrypted secrets.


How to run with Docker
----------------------

Run an interactive shell::

    $ docker-compose run --rm --service-ports bash

Start all services::

    $ docker-compose up -d haproxy

View logs for all services::

    $ docker-compose logs -f

Stop all services::

    $ docker-compose stop


How to run without Docker
-------------------------

Run an interactive shell::

    $ ./go.sh


Requirements when running without Docker
----------------------------------------

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
* git-secret (not recommended)
* Transcrypt


## macOS

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
-------------------------------------------------------------

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
------------------------------------

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
