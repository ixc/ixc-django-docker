======================
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
