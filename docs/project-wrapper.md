Django project wrapper
======================

The `ixc_django_docker` package is a Django project (settings, URLs, etc.) that
*wraps* another project by including additional settings, context processors,
static files, templates, URLs, etc., from the other project.

This makes it easier to enable optional but commonly needed features and evolve
our shared understanding of current best practices over time.

It includes:

* A `manage.py` script that you can execute from any directory when your
  project environment is active.

* [Safe and secure default settings](#safe-and-secure-default-settings) with
  integration hooks for your project.

* Optional [base settings](composable-settings.md#bundled-base-settings)
  modules that solve issues relating to horizontal scaling and ephemeral
  infrastructure or enable commonly needed features, including integrations
  with [LogEntries](https://logentries.com), [New Relic](https://newrelic.com)
  and [Sentry](https://sentry.io).

* [Override settings](composable-settings.md#bundled-override-settings) for
  develop, staging, test, and production environments.

* Lazy public and private storage classes that can be configured as local or
  remote (S3) via the `ENABLE_S3_STORAGE` setting, or use unique (forever
  cacheable) names via the `ENABLE_UNIQUE_STORAGE` setting.

* A `get_local_file_path()` context manager, for when local file system access
  is required (e.g. transcoding an audio file in a subprocess).

* An `environment` context processor that wraps a project context processor
  and includes any settings specified in `CONTEXT_PROCESSOR_SETTINGS`.

* An `environment` function that wraps the `environment` context processor
  and adds `static` and `url` functions, returned as a Jinja2
  `Environment` object, so you can more easily use both Django and Jinja2
  template engines.

* Automatically install Bower components, Node modules and Python packages, or
  apply Django migrations when required, via the `bower-install.sh`,
  `npm-install.sh`, `pip-install.sh` and `migrate.sh` scripts.

* Automatically create required runtime directories via the `RUNTIME_DIRS`
  setting at startup.

* Remote debugging with PyCharm via the `pydevd.sh` script. For example, when
  your application is running in a container or on a remote server.

* Show a test coverage report via the `runtests.sh` script.


Safe and secure default settings
================================

The `ixc_django_docker.settings.base` module includes safe and secure settings
based on the Django 1.8 LTS project template and checklist.

Some of its changes include:

* Define frequently configured settings with their default values, so we can
  more easily extend them in optional settings modules.

* Define settings like `MIDDLEWARE_CLASSES` that have been deprecated and
  removed in recent versions of Django for compatibility with older projects.

* Define `PROJECT_DIR`, `PROJECT_SLUG`, and `VAR_DIR`.

* Get `SECRET_KEY` from the environment *or* generate and save a random key to
  `./var/secret.txt`, which is read only by the owner.

* Use dummy caching, so we don't get confused because a change is not taking
  effect when we expect it to, and so we can execute management commands when
  building a Docker image.

* Don't actually send emails, in case we are running locally with a copy of the
  production database.

* Enable TLS when connecting to the email server.

* Use secure CSRF and session cookies. We should always access hosted
  environments via HTTPS, now.

* Enable persistent database connections.

* Log `INFO` events to `console` and `logfile` handlers.

* Easily reconfigure the level for any logger via `{LEVEL}_LOGGERS` environment
  variable where `{LEVEL}` is `EXCEPTION`, `ERROR`, `WARNING`, `INFO` or
  `DEBUG`. The value should be a space separated list of logger names.

* Easily silence noisy loggers via `NULL_LOGGERS` environment variable.

* Fix HTTPS redirect behind proxy via `SECURE_PROXY_SSL_HEADER`.
