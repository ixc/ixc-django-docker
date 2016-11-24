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

Django project
--------------

* Adds an ``environment`` context processor that returns settings referenced in
  the ``CONTEXT_PROCESSOR_SETTINGS`` setting.

* Adds ``static`` and ``url`` functions to the Jinja2 environment, that
  correspond with the built in Django template tags of the same names.

* Has project hooks for context processors, settings, static files, templates,
  etc.
