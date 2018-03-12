How to run a remote debug server with `pydevd` (e.g. PyCharm)
=============================================================

* Add a `Python Remote Debug` run configuration to PyCharm with the following
  options:

  * Name: `pydevd`
  * Local host name: `localhost`
  * Port: `5678`

* Select the `pydevd` configuration and click the `Debug` icon (`^D`) to start
  the debug server.

* Open an interactive shell with Docker (*or* without, via `go.sh`):

    $ docker-compose run --rm --service-ports bash
    $ ./go.sh

* Execute your command with remote debugging enabled:

    (PROJECT_NAME)$ pydevd.sh runserver.sh

You can reconfigure the default host and port for the remote debug server with
the follow environment variables:

    PYDEVD_HOST=localhost
    PYDEVD_PORT=5678

**NOTE:** When running with Docker you will need to specify your LAN IP address
as `PYENVD_HOST` to establish a connection from the container to PyCharm.
