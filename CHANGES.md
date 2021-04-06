Breaking and notable changes
===

6 April 2021
---

### Breaking

- `django-compressor` and `ixc-whitenoise` will now include a `.$GIT_COMMIT` suffix in their manifest filename, so we can run new and old versions of a codebase side by side with a shared volume.

  When upgrading:

  - To disable this behaviour for local development, where you do not want to re-compress or collect static files for every commit, add the following to your `.env.develop.secret` file:

        # Configure static file manifests. Comment out to save versioned files with a
        # `$GIT_COMMIT` suffix.
        export COMPRESS_OFFLINE_MANIFEST='manifest.json'
        export STATICFILES_MANIFEST='staticfiles.json'

13 November 2020
---

### Breaking

- Use tuple instead of list for template dirs, context processors, loaders. Check if you are using `+= [..., ]` and change to `(..., )`

17 September 2020
---

### Breaking

- `setup.sh` and `setup-tests.sh` no longer automatically run any npm script, even if `SETUP_NPM_RUN` or `SETUP_TESTS_NPM_RUN` is defined.

  Instead, export `SETUP_COMMAND` and `SETUP_TESTS_COMMAND`, which can be any shell command instead of the name of an npm script.

  This allows us to execute any combination of npm scripts in sequence (via `run-s`) or parallel (via `run-p`), without cluttering up `package.json` with near identical wrapper scripts.

  We can also execute any shell script or bash command.

  When upgrading:

  - Add `export SETUP_COMMAND='npm run -l build --if-present'` and `export SETUP_TESTS_COMMAND='npm run -l build --if-present'` to your `.env` file to restore the old behaviour.

  - Or add `export SETUP_COMMAND='...'` to your `.env` file, as required.

- The `COMPRESS_OFFLINE` setting is now `True`. Offline compression is required when using WhiteNoise without autorefresh, which is not used in production because it is only intended for development and has had a serious security issue in the past.

  When upgrading:

  - Add `"compress": "manage.py compress --verbosity=0"` to the `package.json` file.
  - Add `export SETUP_COMMAND='run-s -l compress ...'` to your `.env` file.
  - Add `run-s -l collectstatic compress` to `Dockerfile`.
  - Confirm that your `{% compress %}` blocks do not have any dynamic content (changes with context), or set `IXC_COMPRESSOR_REQUEST`, `IXC_COMPRESSOR_GLOBAL_CONTEXT` and `IXC_COMPRESSOR_OPTIONAL_CONTEXT` accordingly.

### Notable

- Supervisor no longer wraps its programs with `entrypoint.sh`. This was a convenience during troubleshooting so we could edit a dotenv file and restart the program, without having to restart supervisor or the container itself.

  Now that `entrypoint.sh` is optional, it is no longer appropriate to always wrap programs with it.

  If you are still using `entrypoint.sh`, in a pinch you can live edit the supervisor template to reinstate the wrapper.

8 September 2020
---

### Breaking

- `setup.sh` now runs the `setup` npm script instead of `build`, to better reflect its purpose. To upgrade, rename your `build` script to `setup` in `package.json` or export `SETUP_NPM_RUN=build` in your env file(s).
- The hard coded `collectstatic` and `compress` commands have been removed from `runtests.sh`. Instead, the `setup` npm script is run by `setup-tests.sh`. If you need to execute different commands for setup and tests, export `SETUP_TESTS_NPM_RUN=foo` in your env file(s).


27 March 2019
---

### Breaking

- Rename `SUPERVISORD_*` environment variables to `SUPERVISOR_*` for consistency with Supervisor's own environment variables.
- Remove `logentries` program from `supervisor.tmpl.conf`. Add it back via `SUPERVISOR_TMPL_CONF`, if needed.
- Run a single gunicorn process by default. Explicitly set `GUNICORN_WORKERS=auto` for the previous behaviour (2x CPU cores +1 for sync, 1x CPU cores for async).
- Run a single nginx worker process by default. Explicitly set `NGINX_WORKER_PROCESSES=auto` for the previous behaviour (1 per CPU core).
- Remove `www` redirect via nginx when `NGINX_REDIRECT_SERVER_NAME` is defined. Do the redirect in your app or with https://github.com/ixc/nginx-proxy-redirect

### Notable

- Add `prefix-logs.sh` and use it in `supervisor.include.tmpl.conf`. Send program logs directly to stdout and stderr with a prefix, so we don't need `dockerize -stdout ... -stderr ...` anymore.
- Send nginx access log to stdout instead of gunicorn, now that we can send all supervisor program logs directly to stdout and stderr with a prefix.
- Add `SUPERVISOR_NUMPROCS` environment variable, for programs that don't internally run multiple worker processes.
- Each process will have `SUPERVISOR_PROCESS_NUM` environment variable set, which can be used to increment the base `NGINX_PROXY_PORT` (default: 8080) port number.
- Configure nginx to load balance all processes via the default server, AND allow direct access to each process via `s{{ SUPERVISOR_PROCESS_NUM }}.*` subdomains.
- Define default environment variables once in shell scripts instead of config templates, where they are often needed multiple times.
- Disable nginx CPU affinity. Allow workers to execute on any available process.
- Move nginx config from lower to higher contexts (e.g. from `server` to `http`) where possible.


10 July 2018
---

### Breaking

- `djcelery.schedulers.DatabaseScheduler` is no longer hard coded in `celerybeat.sh`. If you want to continue using the database scheduler, add `CELERYBEAT_SCHEDULER = 'djcelery.schedulers.DatabaseScheduler'` to your project settings.

- Offline compression is no longer enabled in `compressor.py` settings, because we now have persistent shared volumes on Docker for AWS. If you want to continue using offline compression, add `COMPRESS_OFFLINE = True` to your project settings.

- `git-secret` is no longer supported. Switch to `transcrypt`, before upgrading.

- SASS/SCSS precompiler has been removed from `compressor.py` settings, because it forks a compiler on every single request when offline compression is disabled. Instead:

  - Add `RUN entrypoint.sh compile-scss.sh` to `Dockerfile` *before* collecting static files.
  - Add `static/COMPILED/` to `.dockerignore` and `/static/COMPILED/` to `.gitignore`.
  - Reference the compiled CSS in templates, instead of the source SCSS. For example: `{% static "COMPILED/scss/foo.css" %}` instead of `{% static "scss/foo.scss" }`.
  - Run `compile-sass.sh --watch` during development.

- Setuptools has vendored its dependencies again. Update `Dockerfile` and `go.sh`, changing `pip install ... -r <(grep -v setuptools requirements.txt)` to `pip install ... -r requirements.txt`

- `setup-django.sh` has been removed in favour of `setup.sh` and `setup-wait.sh`. Add the former to a new `setup` service with no health check. Replace `setup-django.sh` with the latter in existing services, and remove `start_period` from health checks.

- [Dockerize](https://github.com/jwilder/dockerize) is now a required.

### Notable

- If your project uses Python 3, you must export `PYTHON_VERSION=python3` in `Dockerfile`
  *and* specify `--python=python3` in `go.sh` when creating the virtualenv.

- `go.sh` no longer uses the active virtualenv instead of `var/go.sh-venv` when `VIRTUAL_ENV` is set. If you want to continue using a virtualenv in a non-standard location, add `PROJECT_VENV_DIR='path/to/venv/dir'` to your `.env.base` file.

- Editable packages are now always installed in `$PROJECT_DIR/src`, when run with Docker or `go.sh`. If you want to install to a different location, add `PIP_SRC='path/to/src/dir'` to your `.env.local` file.

- Stub `setup.py` files are no longer needed to add the project directory to the Python path.

- Gunicorn now uses `gevent` async worker by default. If you want to continue using the default sync worker, add `GUNICORN_WORKER_CLASS='sync'` to your `.env.base` file.

- `runserver.sh` now runs Gunicorn instead of the Django dev server, with a single async worker, autoreloading enabled, and simplified logging. If you want to run the Django dev server, run `manage.py runserver 0.0.0.0:8000`.

- `bash.sh` sleeps forever when there is no tty. Use this as the command in a `shell` service with no replicas, which you can scale up on demand then exec into to troubleshoot.

- You no longer need to manually terminate existing connections before executing `SETUP_POSTGRES_FORCE=1 setup-postgres.sh` to drop and recreate a database.

- `SETUP_POSTGRES_FORCE=1 setup-postgres.sh` will now prompt for confirmation when there is a tty, for safety.

- You can now exclude unwanted table data when restoring from a source database via `SRC_PGDUMP_EXTRA`. For example, `SRC_PGDUMP_EXTRA='--exclude-table-data django_session --exclude-table-data FOO ...'`

- Management commands executed in `Dockerfile` should be wrapped with `entrypoint.sh` to ensure the runtime environment is properly configured.


16 January 2018
---

- Config templates are now rendered to the `$PROJECT_DIR/var/etc` directory for
  easier discovery and to avoid writing to potentially read-only file systems.

  The default templates can be overridden by setting the `LOGENTRIES_TMPL_CONF`,
  `NEWRELIC_TMPL_CONF`, `NGINX_TMPL_CONF`, `SUPERVISOR_TMPL_CONF`, or
  `SUPERVISOR_INCLUDE_TMPL_CONF` environment variables in your dotenv file.

- `supervisor.sh` no longer attempts to render `$PROJECT_DIR/etc/supervisor.tmpl.conf`
  as an alternative to the default include config (nginx proxy).

  Instead, you should explicitly set `SUPERVISOR_INCLUDE_TMPL_CONF=$PROJECT_DIR/etc/supervisord.include.tmpl.conf`
  in your dotenv file.
