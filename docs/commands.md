Terminal commands
=================

This document summarises the purpose and main actions of the terminal commands
provided by `ixc-django-docker`.

You can override any of the following commands by adding a custom version to
the `$PROJECT_DIR/bin/` directory.

**TODO:** This document is incomplete, there are many scripts not yet
documented.


go.sh
=====

Configures a native (non-Docker) environment just enough so that
[entrypoint.sh](#entrypoint.sh) can execute without Docker.

**NOTE:** Unlike all the other commands documented here, `go.sh` is part of the
[project template](project-template.md) and must be copied into and run from
your project directory.

**Actions:**

* Determine the absolute path to the project directory. That is, the directory
  containing `go.sh`.
* Create a Python virtualenv.
* Install Python packages from `requirements.txt`, which should include
  `ixc-django-docker`, and reinstall them when that file changes.
* Configure the environment via `entrypoint.sh` and execute the command given
  as arguments (default: `setup-django.sh bash.sh`).

**Inputs:**

* A `.env.local` file is **required** at root directory and must contain at
  least the following bootstrap environment variables:

  * `DOTENV` - the environment name, defining which `.env.$DOTENV.secret` file
    will be sourced and which default override settings module will be included.
  * `TRANSCRYPT_PASSWORD` - the password for encrypted secrets via
    [Transcrypt](https://github.com/elasticdog/transcrypt).
  * `GPG_PASSPHRASE` **DEPRECATED** - the passphrase for encrypted secrets
    via [Git Secret](https://github.com/sobolevn/git-secret).

**Outputs:**

* `PROJECT_DIR` - absolute path to the directory containing `go.sh`.
* `PROJECT_VENV_DIR` - absolute path to the virtualenv. Set to `$VIRTUAL_ENV`,
  if a virtualenv is already active, otherwise creates a new virtualenv in
  `$PROJECT_DIR/var/go.sh-venv`.


entrypoint.sh
=============

Configures the environment in such a way that our terminal commands and project
config work consistently with *and* without Docker (via `go.sh`), and then
executes a command (default: `bash.sh`) within the configured environment.

**IMPORTANT**: This script is critical and **MUST** run before you can execute
any other commands.

**Actions:**

* If the project directory is a Git working copy, log the commit hash to stdout.
* If running with Docker:

  * Configure `pip` and `Python` to install additional packages into
    `$PROJECT_DIR/var/docker-pythonuserbase` via the `user` alternative
    installation scheme, which allows us to install additional Python packages
    during development that persist across containers.
  * If running Docker for Mac, set `DOCKER_FOR_MAC=1`, which can then be used
    to avoid performance problems related to watching file system events.

* If running without Docker (via `go.sh`):

  * Assert `PROJECT_DIR` and `PROJECT_VENV_DIR` environment variables are set.
    **TODO:** Do this in all cases for `PROJECT_DIR`, not only without Docker?
    (Not necessary, `Dockerfile` ensures that `PROJECT_DIR` is set.)
  * Assert that required system packages are installed.
    **TODO:** Do this in all cases, not only non-Docker? (Not necessary,
    `Dockerfile` ensures that required system packages are installed.)
  * Assert that required `.env.local` file exists.

* Add `$IXC_DJANGO_DOCKER_DIR/bin` to system path, so terminal command changes
  are picked up immediately during development.
* Add `$PROJECT_DIR/bin/` directory to system path, so you easily can override
  the bundled terminal commands.
* Source `.env.local` for bootstrap environment variables.
* Decrypt secrets via Transcrypt or Git Secret (via `setup-git-secret.sh`).
* Source environment variables from `.env.base`, `.env.$DOTENV.secret`, and
  `.env.local` (again), when those files exist.
* If the `PGDATABASE` environment variable is not set, derive it from one of
  the following (in this order):

  * `$PROJECT_NAME_<git-branch>`, if the project directory is a Git repository.
  * `$PROJECT_NAME_$DOTENV`, if `$DOTENV` is set.
  * `$PROJECT_NAME`.

* Pass through or set sensible default values for PostgreSQL and Redis
  connection settings.
* Exec any command arguments passed to this script, otherwise `bash.sh`.

**Inputs:**

* `HOME` - absolute path to user home directory. **TODO:** Really?
* `PROJECT_DIR` - absolute path to project directory.
* `.env.local` - file to set bootstrap and override environment variables.
  **TODO** Are specific variables required, as stated for `go.sh`?
* `.env.base` and `.env.$DOTENV.secret` - **optional** files to set global and
  encrypted (secret) environment variables.
* `PGDATABASE`, `PGHOST`, `PGPORT`, `PGUSER` and `REDIS_ADDRESS` - **optional**
  PostgreSQL and Redis connection settings. Sensible defaults will be used if
  they are not provided.

**Outputs:**

* If running with Docker:
  * `PYTHONUSERBASE` set to `$PROJECT_DIR/var/docker-pythonuserbase`.
  * `PIP_SRC` set to `$PYTHONUSERBASE/src`.
  * `PATH` set to `$PYTHONUSERBASE/bin:$PATH`.
  * `DOCKER_FOR_MAC=1`, if running with Docker for Mac.
* If running without Docker (via `go.sh`):
  * `PATH` set to `$PROJECT_VENV_DIR/bin:$PATH`
* In all cases:
  * `IXC_DJANGO_DOCKER_DIR` set to the absolute path for the `ixc_django_docker`
    Python package.
  * `PATH` set to `$PROJECT_DIR/bin:$IXC_DJANGO_DOCKER_DIR/bin:$PATH`
  * `CPU_CORES` set to the number of available processor cores.
  * `PROJECT_NAME` set to the base name of `$PROJECT_DIR`.
  * `PGDATABASE` passthrough, or defaults to `$PROJECT_NAME_<git-branch>` or
    `$PROJECT_NAME_$DOTENV` or `$PROJECT_NAME`.
  * `PGHOST` passthrough, or defaults to `localhost`.
  * `PGPORT` passthrough, or defaults to `5432`.
  * `PGUSER` passthrough, or defaults to `$(whoami)` (local username).
  * `REDIS_ADDRESS` passthrough, or defaults to `localhsot:6379`.


bash.sh
=======

Runs an interactive Bash shell without any user customisations from rc or
profile files, to reduce the chance of user customisations clashing with our
paths etc.

**Actions:**

* Print help text showing available terminal commands with links to `help.sh`
  and this documentation.
* Set a usable shell prompt including the project name, local username, host
  and and current working directory.
* Execute Bash without any user customisations from rc or profile files.

**Outputs:**

* `PS1` set to `($PROJECT_NAME) \u@\h:\w\\$ `.
