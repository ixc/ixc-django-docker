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


Remote debug server with `pydevd` (e.g. PyCharm)
------------------------------------------------

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
