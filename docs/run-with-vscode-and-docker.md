# Visual Studio Code & Docker

This document describes how to run an [ixc-django-docker] project with Visual Studio Code and Docker.

## Benefits

Why would you want to run a project with Visual Studio Code & Docker?

- Faster system setup with minimal dependencies. Just Visual Studio Code and Docker.
- Faster project setup. Download a base image instead of compiling and installing most dependencies.
- Run in an environment that more closely matches production.
- Automatically start and stop services when opening and closing a Visual Studio Code workspace. No dangling elasticsearch, postgres and redis containers running in the background without your knowledge.
- IntelliSense for Python packages installed inside the container (e.g. `Go to Definition`).
- Automatically forward exposed ports in `docker-compose.yml` (e.g. 8000 for runserver), and fallback to dynamic ports if already in use (e.g. when running multiple projects at the same time).
- Quickly jump between code and terminal with `CTRL-(backtick)`.

Why would you not want to?

- Potential performance issues with Docker bind mount volumes on macOS.

## Requirements

Install [Docker], [Visual Studio Code], and the [Remote - Containers] extension. These are the only system dependencies you will need on Linux, macOS and Windows.

[Docker]: https://docs.docker.com/get-docker/
[ixc-django-docker]: https://github.com/ixc/ixc-django-docker/
[Remote - Containers]: https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers
[Visual Studio Code]: https://code.visualstudio.com/

## Getting started

1. Clone the project repository.

        git clone git@github.com:${ORG}/${REPO}.git

2. Open the project directory in Visual Studio Code.

3. Save a copy of `.env.example` as `.env` and update `TRANSCRYPT_PASSWORD` (get from 1Password).

4. Click the automatic `Reopen in Container` alert (bottom right), or click `><` (bottom left) > `Reopen in Container`.

5. Click the `Starting with Dev Container` alert (bottom right) to watch the logs, or just wait.

6. Hit `CTRL-SHIFT-(backtick)` to open a new terminal. A project shell (`entrypoint.sh`) will open when the container is ready.

## Restore initial database dump

If you have network access to the production database and `SRC_PG*` are defined in `.env.develop.secret`, run `setup.sh` to create and restore a local database from there.

Otherwise, save a recent production database dump as `initial_data.sql` and uncomment `export SRC_PGDATABASE='initial_data.sql'` in `.env`.

## Run

Run commands as needed from the project shell, `runserver.sh`, `runtests.sh`, `manage.py shell_plus`, `run-p celery runserver` (multiple specific npm scripts), `npm run dev` (all npm scripts typically needed for dev), `docker-compose exec redis ...`, etc.

Access the site at `http://${PROJECT}.lvh.me:8000` to isolate cookies across projects.

## Run with debugger

Hit `F5` or `CMD-SHIFT-D` and click the `Start Debugging` (play) icon to launch runserver with debug support. Set breakpoints, watch expressions, hover over variables, etc.

## Run multiple projects

Visual Studio Code will forward the ports defined in `docker-compose.yml` automatically (e.g. 8000 for runserver), and fallback to a dynamic port if the preferred port is already in use.

Go to `Remote Explorer` (sidebar) > `Forwarded Ports` to find the dynamic port number to use when running multiple projects at the same time.

## Shutdown and cleanup

Click `>< Dev Container` > `Reopen Locally` or just close the window to shutdown all containers.

## Reset and start from scratch

Remove all containers and volumes (e.g. elasticsearch, postgres, redis):

    docker-compose down -v

Then reload the Visual Studio Code window when prompted.

## Manually build the base image

If you have not already pushed a commit to a branch and had Codefresh successfully build and push an image to the registry, you can manually build the base image for local use:

    docker build -t interaction/{REPO}:master -f Dockerfile.base .

## Switching branches

It is usually safe to use the `master` base image for feature branches, unless you have changed `Dockerfile.base` or `docker-compose.yml`.

In that case, set `IMAGE_TAG` in `.env` and click `>< Dev Container` > `Rebuild Container`.

## Compatibility with Docker Compose

Visual Studio Code uses the same `docker-compose.yml` file that you can also use when you run `docker-compose` commands in a terminal outside of Visual Studio Code.

For example, you can start your containers manually from any terminal and then attach from Visual Studio Code, or start them with Visual Studio Code and then exec into them from any terminal.
