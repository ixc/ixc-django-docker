Composable settings
===================

The `ixc_django_docker.settings` package includes many composable settings
modules that can be combined as required to enable optional features.

These settings modules are included and combined via
[django-split-settings](https://github.com/sobolevn/django-split-settings).

Think of settings as a hierarchy:

* **base** settings are included from `ixc_django_docker.settings` for critical
  and optional but commonly needed config.

* **project** settings are included from `ixcproject.settings.base` for project
  specific config, and they override *base* settings.

* **override** settings are included from `ixc_django_docker.settings` *and*
  `ixcproject.settings` for environment specific config, and they override both
  *base* and *project* settings.

* **dotenv** environment variables are sourced from `.env.base`,
  `.env.DOTENV.secret` and `.env.local` files, and they are available to Bash
  scripts, running processes and *base*, *project* and *override* settings.

To configure your project, define the following environment variables:

* `BASE_SETTINGS` - A space separated list of *base* settings modules to be
  included from `ixc_django_docker.settings`.

  Default: `base.py compressor.py logentries.py storages.py whitenoise.py`
  (Just enough to solve the most common horizontal scaling and ephemeral
  infrastructure issues.)

* `PROJECT_SETTINGS` - A single settings module to be included from
  `ixcproject.settings`.

  Default: `base.py`

* `OVERRIDE_SETTINGS` - A single settings module to be included from
  `ixc_django_docker.settings` *and* `ixcproject.settings`.

  Default: `$DOTENV.py`

* `DOTENV` - The `.env.$DOTENV.secret` file to be sourced by `entrypoint.sh`.

  Default: Undefined

**IMPORTANT:** All settings modules should be specified as file system paths
relative to the settings package they are to be included from, not dotted path
module names.


How to specify environment variables
====================================

With Docker Compose or `go.sh`, you *must* create a `.env.local` file which
specifies at least `DOTENV` and `TRANSCRYPT_PASSWORD`.

With Docker Cloud, you must specify these in your stack file for every
`ixc-django-docker` based service.

All other environment variables can then be specified in `.env.base` and
`.env.$DOTENV.secret` files.

**NOTE:** `.env.local` is sourced *twice*. Once to get `DOTENV` and
`TRANSCRYPT_PASSWORD` which are required to decrypt `.env.$DOTENV.secret`, then
again to override any conflicting environment variables.


Bundled base settings
=====================

* `base.py` - Safe default settings, based on Django 1.8 LTS project template
  and checklist.

  See [Safe and secure default settings](project-wrapper.md#safe-and-secure-default-settings)
  docs for more.

  **NOTE:** This settings module is *required*.

* `celery.py` - Use [Celery](http://docs.celeryproject.org/en/latest/index.html)
  and [Celery Beat](http://docs.celeryproject.org/en/latest/userguide/periodic-tasks.html)
  for asynchronous and scheduled task processing.

* `celery_email.py` - Use [django-celery-email](https://github.com/pmclanahan/django-celery-email)
  for asynchronous email delivery via Celery.

* `compressor.py` - Use [django-compressor](https://github.com/django-compressor/django-compressor)
  to compile and compress CSS, JavaScript, Less, Sass, etc.

* `debug_toolbar.py` - Enable [django-debug-toolbar](https://github.com/jazzband/django-debug-toolbar).

* `extensions.py` - Use [django-extensions](https://django-extensions.readthedocs.io/en/latest/)
  for convenience and debugging (`manage.py shell_plus`, Werkzeug, etc.)

* `haystack.py` - Use [django-haystack](https://github.com/django-haystack/django-haystack) with
  [ElasticSearch](https://www.elastic.co/) backend for search.

* `logentries.py` - Enable [LogEntries](https://logentries.com/) integration
  for persistent log storage and aggregation. See the [Logging](logging.md)
  docs for more.

  **NOTE:** Requires a LogEntries account and the `LOGENTRIES_TOKEN`
  environment variable.

* `master_password.py` - Use [django-master-password](https://github.com/ixc/django-master-password)
  to accept a master password for any account.

  **NOTE:** Requires the `MASTER_PASSWORD` environment variable.

  **WARNING:** This is not recommended for production environments. When
  `DEBUG=False`, the master password *must* be **strong** and **encrypted**
  (see `manage.py make_password`).

* `nose.py` - Use [django-nose](https://github.com/django-nose/django-nose)
  with [nose-exclude](https://github.com/kgrandis/nose-exclude) and
  [nose-progressive](https://github.com/erikrose/nose-progressive) when running
  tests.

* `post_office.py` - Use [django-post-office](https://github.com/ui/django-post_office)
  for asynchronous email delivery and logging.

* `redis_cache.py` - Use [python-redis-lock](https://github.com/ionelmc/python-redis-lock)
  as the default cache backend, for performance and convenience.

  **NOTE:** Requires a Redis server and the `REDIS_ADDRESS` environment
  variable.

* `sentry.py` - Use [Sentry](https://sentry.io/) for server error aggregation
  and alerts.

  **NOTE:** Requires a Sentry account or private instance and the `SENTRY_DSN`
  environment variable.

* `storages.py` - Use [django-storages](https://github.com/jschneier/django-storages)
  to enable remote storage on AWS S3.

  **NOTE:** Requires an AWS S3 bucket and IAM user with appropriate permissions,
  and the `MEDIA_AWS_ACCESS_KEY_ID`, `MEDIA_AWS_SECRET_ACCESS_KEY`, and
  `MEDIA_AWS_STORAGE_BUCKET_NAME` environment variables.

* `whitenoise.py` - Use [whitenoise](https://github.com/evansd/whitenoise) and
  [ixc-whitenoise](https://github.com/ixc/ixc-whitenoise) to serve static files
  *and* media.


Bundled override settings
=========================

* `develop.py` - Enable `DEBUG` mode, relax security, etc.

* `test.py` - Enable `DEBUG` mode, relax security, enable caching, configure
  test database, etc.

* `staging.py` - Reconfigure logging, enable caching, etc.

* `production.py` - Reconfigure logging, enable caching, reconfigure email
  backend (actually send emails), etc.
