# How do I upgrade a project stack?

In this context, upgrading a stack means updating the way we run, deploy and host a project to be consistent with current practices. We should be able to update most stack components, with minimal code changes to the project itself.

## Overview

Briefly, here are the most important steps:

- Update the [buildpack-deps] base image.

- Update [ixc-django-docker] to the latest version.

- Update the `requirements.in` and `requirements.txt` files to resolve nested dependency version conflicts.

- Update the `docker-compose.yml` and `go.sh` files so we can run the project for local development, with and without Docker.

- Update the `codefresh.yml` file so we can automatically build, push and test images on git push.

- Update the `docker-compose.yml` file in the [ixc/stacks] repo so we can deploy and run the project on a "stacks" server.

[buildpack-deps]: https://github.com/ixc/buildpack-deps
[ixc-django-docker]: https://github.com/ixc/ixc-django-docker
[ixc/stacks]: https://github.com/ixc/stacks

## Update the [buildpack-deps] base image

The base image is used by all projects hosted with Docker, and is periodically rebuilt with security updates and for each new Ubuntu LTS release.

If there is a new Ubuntu LTS release available, add a new `Dockerfile` and update `codefresh.yml` and `docker-compose.yml`.

Update `Dockerfile` for ALL releases:

- The Python versions provided by that Ubuntu LTS release.
- The installation steps and Docker version for that Ubuntu LTS release. See: https://docs.docker.com/engine/install/ubuntu/
- The Docker Compose version. See: https://github.com/docker/compose/releases
- The Dockerize version. See: https://github.com/jwilder/dockerize/releases
- The Tini version. See: https://github.com/krallin/tini/releases

## Update the [ixc-django-docker] project template

We will be using this template as a guide, so first make sure it is up to date. Compare all files in the [project_template] directory with recent client projects, and incorporate any generally useful changes.

Pay special attention to:

- [codefresh.yml](https://github.com/ixc/ixc-django-docker/blob/master/project_template/codefresh.yml)
- [docker-compose.yml](https://github.com/ixc/ixc-django-docker/blob/master/project_template/docker-compose.yml)
- [Dockerfile](https://github.com/ixc/ixc-django-docker/blob/master/project_template/Dockerfile)
- [go.sh](https://github.com/ixc/ixc-django-docker/blob/master/project_template/go.sh)
- [package.json](https://github.com/ixc/ixc-django-docker/blob/master/project_template/package.json)

**NOTE:** Changes that are not generally applicable to most projects should NOT be added to the project template.

[project_template]: https://github.com/ixc/ixc-django-docker/blob/master/project_template

## Update `requirements.in` and `requirements.txt` files

About these two files:

- `requirements.in` should be a list of top level (project) dependencies ONLY that are either unpinned or contain version specifiers that **exclude known incompatible versions**.

- Forks and packages that are not available on PyPI should also be specified in `requirements.in` as  editable VCS links, pinned to a specific commit.

- `requirements.txt` should be a flattened list of ALL (nested) dependencies with pinned versions and no conflicts, compiled with [pip-tools].

Making this true can be difficult, because older projects have varying degrees of specificity and consistency in this file.

First, install [pip-tools] with the same Python version that your project is targeting:

    pyenv install -s 2.7.17
    pyenv local 2.7.17
    pip install pip-tools

**NOTE:** If you run `pip-compile` with Python 3 while your project is targeting Python 2, or vice versa, you may get errors about missing packages if a specified package version does not support both versions of Python.

The process to update `requirements.in` and recompile is:

- If `requirements.in` is missing, copy dependencies from `requirements.txt` or `setup.py`.

- Add or update the editable [ixc-django-docker] install, with any "extras" needed by the project.

- Remove exact version specifiers.

- Add exlusion specifiers to avoid known incompatible versions.

- If `requirements.txt` is not already compiled with [pip-tools], replace it with the output from `pip freeze` on production.

- Run `pip-compile -r` to recompile without cache. This will detect and correct most conflicts, using `requirements.txt` as a starting point to avoid eagerly upgrading everything.

- Manually resolve any conflicts and repeat. To speed up subsequent runs, use `pip-compile` to use the package cache.

- Look at the comments in `requirements.txt` to identify nested dependencies, then remove each one from `requirements.in` unless it is imported and used directly in project code, or you have specified extras or an exclusion specifier.

[pip-tools]: https://github.com/jazzband/pip-tools

## How to manually resolve dependency version conflicts

If there is a conflict that [pip-tools] cannot resolve automatically, you will get a helpful error like this:

    Could not find a version that matches django<1.9,>1.3,>=1.11.17,>=1.4,>=1.4.2,>=1.4.3,>=1.7 (from -r requirements.in (line 56))
    Tried: 1.1.3, ..snip.., 1.11.29
    Skipped pre-versions: 1.8a1, ..snip.., 1.11rc1
    There are incompatible versions in the resolved dependencies:
      django<1.9 (from -r requirements.in (line 56))
      ..snip..
      Django>=1.11.17 (from django-celery-beat==2.0.0->ixc-django-docker[..snip..]->-r requirements.in (line 7))

In the first line, we can see that `django<1.9,>=1.11.17` are conflicting. In subsequent lines, we can see that `django<1.9` is from our `requirements.in` file, and `django>=1.11.17` is from `django-celery-beat==2.0.0->ixc-django-docker[..snip..]`.

Investigate release notes and `setup.py` blame on GitHub to determine the latest compatible version for the conflicting package. In this case, [GitHub blame for django-celery-beat](https://github.com/celery/django-celery-beat/blame/74396f0/requirements/runtime.txt#L2) shows that requirement was added in `1.6.0`.

Resolve in `requirements.in` with:

    # Resolve nested dependency version conflicts.
    django-celery-beat<1.6  # Requires django>=1.11.17

## Update the project

Incorporate the latest changes from the ixc-django-docker [project_template] directory while retaining project specific customisations:

- You should already have a flattened list of nested dependencies in `requirements.txt` (see above).

- Update `.env.base`. Define `${DJANGO_SETTINGS_MODULE}` to completely bypass ixc-django-docker [split settings], or `${BASE_SETTINGS}` to use them.

- Update `.env.${DOTENV}.secret` (e.g. develop, staging, production). See: [.env.secret.sample]

- Update `.env.local.sample`. Define `${DOTENV}`, `${SITE_DOMAIN}` and `${TRANSCRYPT_PASSWORD}`.

- Update `package.json`.

  - Define setup scripts (e.g. `build`, `build-dev`, `collectstatic`, `webpack`, etc.)
  - Define service scripts (e.g. `celery`, `celerybeat`, `celeryflower`, `runserver`, etc.)
  - Define a `dev` script that runs all services for local development.

- Update `Dockerfile` and `Brewfile`. Update system requirements (e.g. Node.js) to the latest LTS release.

- Update `docker-compose.yml`. Keep it simple, this is just for running tests on Codefresh and local dev.

- Update `codefresh.yml`. Build image, run tests, push image.

- Update `go.sh`. Validate and configure the environment to match the Docker image.

- Update `.dockerignore` and `.gitignore`. The former should be a copy of the latter, plus secrets. Remove vestigial ignores.

- Update `.python-version` to match the Python version in the Docker image.

- Check and remove vestigial files. For example:
  - `*.egg-info/`
    - This may be leftover from editable installs of the project itself (via `setup.py`). It is no longer necessary, and can confuse pip.
  - `bin/*`
  - `etc/*`
  - `docker-cloud.yml`
  - `docker-compose.*.yml`
  - `docker-swarm.yml`
  - `gulpfile.js`
  - `manage.py`
  - `requirements-*.txt`
  - `setup.py`
  - `supervisord.conf`
  - `tox.ini`

- Merge all app `static` and `templates` directories to corresponding directories in the project root.

  - Update the `FLUENT_PAGES_TEMPLATE_DIR` setting, if necessary.
  - Remove now empty "layouts"  apps from `INSTALLED_APPS` setting and the file system.

- Move any `test_*.sql` file to `${PROJECT_DIR}/test_initial_data.sql`.

- Update project settings:

  - Get secret and environment specific settings from environment variables defined in `.env.${DOTENV}.secret` files.
  - Delete settings for disused apps (e.g. `django-supervisor`).
  - Replace custom or official [whitenoise] middleware (if used) with `ixc_whitenoise.middleware.WhiteNoiseMiddleware`.
  - See below for more on updating to ixc-django-docker [split settings].

- Run `manage.py makemigrations`

  - If migrations were created in any 3rd party library, check to see if these migrations were added upstream and upgrade to that version.
  - If migrations were created in the project, commit them.

Test your changes:

- Run `docker-compose build` and `docker-compose run --rm -p 8000:8000 django` to get an interactive shell with Docker.
- Run `brew bundle` and `./go.sh`, to get a native interactive shell.
- From an interactive shell, run `setup.sh`, `runtests.sh`, `runserver.sh`, `celery.sh`, `npm run dev`, etc.

Things to watch out for:

- Run `rm -rf var` and `find . -name "*.md5" -delete` to reset the environment and start over.

- Upgrading Node.js can require that we also upgrade dependencies in `package.json`. If you see any npm errors during setup:

  - Check `npm outdated` for missing packages.
  - Run `npm update ${PACKAGE}` to update while respecting semver.
  - If that doesn't work, run `npm install -S ${PACKAGE}@latest`. Note that packages with new major versions may have breaking changes.

- Define `${NOSE_EXCLUDE_DIRS}` in `.env.base` to skip tests found in 3rd party editable packages.

- Manually test (in a browser) that updates to `requirements.txt` have not caused any issues.

[.env.secret.sample]: https://github.com/ixc/ixc-django-docker/blob/master/project_template/.env.secret.sample
[split settings]: https://github.com/ixc/ixc-django-docker/blob/master/ixc_django_docker/settings
[whitenoise]: https://github.com/evansd/whitenoise

## About ixc-django-docker [split settings]

By default ixc-django-docker will use internal [split settings] settings and root URLconf.

Configure as follows:

- Base project settings will be loaded from `${PROJECT_SETTINGS}`, `djangosite/settings/base.py`, or `project_settings.py`.
  - Define `${DJANGO_SETTINGS_MODULE}` to completely bypass.
- `${BASE_SETTINGS}` defines which [split settings] will be used.
- Root project URLs will be included from `${PROJECT_URLS}`, `djangosite/urls.py`, or `project_urls.py`.
  - Define `ROOT_URLCONF` setting to completely bypass.

If you do want to use [split settings], here's how to migrate:

- Compare your existing base, develop, staging, production, and calculated project settings with the [split settings] modules.

- Update relative imports to absolute. [split settings] are concatenated and evaluated, not imported individually. Imports will be relative to `ixc_django_docker.settings`.

- Delete any project settings that are default boilerplate, or for which [split settings] already provide a sensible value. For example:

  - `SITE_DOMAIN`, `SITE_PORT`, `BASE_DIR`, `VAR_DIR`, `SECRET_FILE`, `DEBUG`, `ALLOWED_HOSTS`, `CACHES`, `DATABASES`, `EMAIL_*`, `STATIC_*`, `MEDIA_*`, `CONN_MAX_AGE`, `LOGGING`, `ADMINS`, `MANAGERS`, `AUTHENTICATION_BACKENDS`, `CSRF_COOKIE_DOMAIN`, `LANGUAGE_COOKIE_DOMAIN`, `SESSION_COOKIE_DOMAIN`, `*_EMAIL`, `LANGUAGE_CODE`, `*_URL`, `SECURE_PROXY_SSL_HEADER`, `SESSION_COOKIE_NAME`, `SESSION_ENGINE`, `SILENCED_SYSTEM_CHECKS`, `STATICFILES_DIRS`, `STATICFILES_FINDERS`, `TIME_ZONE`, `USE_ETAGS`, `USE_I18N`, `USE_L10N`, `USE_TZ`, `WSGI_APPLICATION`, `SECRET_KEY`, `ROOT_URLCONF`, etc.

- Typically, you will only keep things like `INSTALLED_APPS`, `MIDDLEWARE`, `MIDDLEWARE_CLASSES`, 3rd party app settings not configured by ixc-django-docker, and local project settings.

- Update any list and dict settings to update instead of overwriting the [split settings] defaults. For example:

  - `MIDDLEWARE += (mine, )`
  - `TEMPLATES[0]['OPTIONS']['context_processors'].append(mine)`

- Remove redundant `*.environment` context processor and `*.jinja2.environment` function, and configure the `CONTEXT_PROCESSOR_SETTINGS` setting, instead.

- Move the project base settings module to `djangosite/settings/base.py`, and develop, staging, production and test settings modules (if they exist) to `develop.py`, `staging.py`, `production.py`, and `test.py` in the same directory.

- Merge all existing URLconf modules into `djangosite/urls.py`, and remove any URLs that are duplicated in `ixc_django_docker/urls.py`.

- Replace `node-sass` with the new canonical `sass` implementation:

  - Remove `text/x-scss` from `COMPRESS_PRECOMPILERS`. [See why...](https://github.com/ixc/ixc-django-docker/blame/b194fa1f2246db7a7bfa2b8eb1959ad43f4799ab/CHANGES.md#L39-L44)
  - Remove `node-sass` from `package.json` and run `npm install -S sass`.
  - Call `compile-sass.sh` in npm `build` script, and `compile-sass.sh --watch` in `build-dev` script.
  - Update `path/filename.scss` links in templates `COMPILED/path/filename.css`.

- Rename the directory referenced by `WHITENOISE_ROOT` to `${PROJECT_DIR}/whitenoise_root`.

- Remove `djangosite/celery.py` and the celery import from `djangosite/__init__.py`.

## Update the stack compose file

The [ixc/stacks] repo holds `docker-compose.yml` and `.envrc.example` files that are suitable for deployment on a production or staging "stack server".

When you update the way we run and deploy a project, you will also need to update the corresponding stack compose file in this repo. Use the [stacks project template] as a guide.

Things to check:

- Use the full client name in slug form in the `ic.billing` label. Double check existing `billing_group` tags in AWS cost explorer for an exact match.
- Find a replace `project_name` with the project name in slug form.
- Avoid running heavy services (e.g. elasticsearch) or services require data persistence (e.g. postgres) directly in the project stack. Use managed services (e.g. RDS) or shared system services.

[stacks project template]: https://github.com/ixc/stacks/blob/master/project_template
