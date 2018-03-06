======================================
Commands in ixc-django-docker projects
======================================

This document summarises the purpose and main actions of scripts provided in
``ixc_django_docker`` projects.

You can override ``ixc_django_docker`` scripts with custom versions in projects
by adding a ``bin/`` directory to the project.

**TODO:** This document is incomplete, there are many scripts not yet
documented.


go.sh
=====

Bootstrap a pre-configured interactive Bash shell environment for running the
project without Docker, in particular so we can run ``entrypoint.sh``.

Note that unlike all the other commands documented here, ``go.sh`` must be
installed into, and run from, the project root directory, not from the
``ixc_django_docker/bin`` location.

Actions:

* Create virtualenv for project
* (Re)install Python requirements from ``requirements.txt`` when this file
  changes, as detected via hash file ``requirements.txt.md5``
* Source bootstrap environment variables from ``.env.local``
* Exec ``entrypoint.sh`` with command arguments passed to this script if any,
  otherwise with ``setup-django.sh bash.sh``

Inputs:

* ``.env.local`` file is **required** at root directory and must contain
  bootstrap environment variables:

  * ``DOTENV`` sets the environment name, defining which files like
    ``.env.$DOTENV`` and similar will be loaded to set further environment
    variables
  * ``TRANSCRYPT_PASSWORD`` sets the project password for transparently
    encrypting and decrypting secret values from ``*.secret`` files with the
    Transcrypt tool
  * ``GPG_PASSPHRASE`` **used in legacy projects only** sets the project
    password for handling secrets with `git-secret <http://git-secret.io/>`_

Outputs:

* ``PROJECT_DIR`` to absolute directory path containing this ``go.sh`` script
* ``PROJECT_VENV_DIR`` to location of virtualenv. Matches the ``VIRTUAL_ENV``
  envvar if that is set, otherwise ``$PROJECT_DIR/var/go.sh-venv``


entrypoint.sh
=============

The **central and key** script that configures the shell environment in which
subsequent ``ixc-django-docker`` scripts will work.

This script works in both a Docker environment or in a shell-only local
development environment generally bootstrapped with ``go.sh``.

In common development usage it sets up the environment then calls the
``bash.sh`` script to provide an interactive shell for futher commands.

Actions:

* Print Git Commit hash of project for logging, if available
* If running on a Docker container (``/.dockerenv`` file exists):
  * Configure ``pip`` and the project to use a specific "userbase" directory
    for additional non-system Python libraries (in place of a virtualenv)
  * Detect when running in Docker on MacOS and set ``DOCKER_FOR_MAC=1`` if so:
    a flag used by later scripts to avoid performance problems
* If not running on a Docker container (e.g. via ``go.sh`` instead):
  * Assert ``PROJECT_DIR`` and ``PROJECT_VENV_DIR`` environment variables are
    set
    **TODO** Do this in all cases for ``PROJECT_DIR``, not only non-Docker?
  * Assert required system packages are installed
    **TODO** Do this in all cases, not only non-Docker?
* Add script directories for requirements to system path
* Source ``.env.local`` for bootstrap environment variables
* Decrypt project secret files using Transcrypt and/or git-secret tools (the
  separate script `setup-git-secret.sh`_ is used for git-secret files)
* Source environment variables from dotenv files ``.env.base``,
  ``.env.$DOTENV.secret``, and ``.env.local`` (again) when those files exist
* If the PostgreSQL DB name ``PGDATABASE`` environment variable is not set,
  derive it from one of the following in, order of preference:
  * ``$PROJECT_NAME_<Git branch>`` if a Git repository is present
  * ``$PROJECT_NAME_$DOTENV`` if ``DOTENV`` is set
  * ``$PROJECT_NAME`` if neither of the two situations above holds.
* Pass through or set sensible default values for PostgreSQL and Redis
  connection settings
* Exec any command arguments passed to this script, otherwise ``bash.sh``

Inputs:

* ``HOME`` - user home directory path
* ``PROJECT_DIR`` - path to ``ixc-django-docker`` project root directory
* ``.env.local`` file to set bootstrap environment variables
  **TODO** Are specific envvars required, as stated for ``go.sh``?
* ``.env.base`` and ``.env.$DOTENV.secret`` are **optional** files to set
  further environment variables
* PostgreSQL connection settings ``PGDATABASE``, ``PGHOST``, ``PGPORT``, and
  ``PGUSER`` are **optional**, sensible defaults will be used if they are not
  provided

Outputs:

* If running on a Docker container:
  * ``PYTHONUSERBASE`` set to ``$PROJECT_DIR/var/docker-pythonuserbase``
  * ``PIP_SRC`` set to ``$PYTHONUSERBASE/src``
  * ``PATH`` adjusted to prepend ``PYTHONUSERBASE/bin``
  * If running on MacOS:
    * ``DOCKER_FOR_MAC=1`` set if Docker is running on MacOS
* If not running on a Docker container:
  * ``PATH`` adjusted to prepend ``PROJECT_VENV_DIR/bin``
* ``IXC_DJANGO_DOCKER_DIR`` set to absolute dir for the ``ixc_django_docker``
  Python package
* ``PATH`` adjusted to prepend ``bin`` directories for Node and
  ``ixc_django_docker``
* ``CPU_CORES`` set to number of processor cores
* ``PROJECT_NAME`` set to the base name of ``$PROJECT_DIR``
* ``PGDATABASE`` as provided in inputs, else derived from project name
* ``PGHOST`` as provided in inputs, else defaults to ``localhost``
* ``PGPORT`` as provided in inputs, else defaults to ``5432``
* ``PGUSER`` as provided in inputs, else defaults to local username
* ``REDIS_ADDRESS`` as provided in inputs, else defaults to ``localhsot:6379``


bash.sh
=======

Run an interactive Bash shell, most likely only ever within a shell environment
set up by `entrypoint.sh`_.

Actions:

* Print help text showing available commands and a pointer to ``help.sh``
* Set a usable shell prompt
* Exec the ``bash`` shell executable without any loading of user customised
  profiles or rc files.

Outputs:

* Set a default shell prompt in ``PS1``
