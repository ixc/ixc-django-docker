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
  for persistent log storage and aggregation. See `Logging with LogEntries
  <logging.rst>`_ for more information.

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

