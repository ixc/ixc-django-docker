# Using Docker

## Run an interactive project shell with Docker

### macOS

**WARNING:** Docker for Mac has significant performance issues due to its
implementation of bind mounted volumes. Fortunately, we can work around them to
get near native level performance with [docker-sync](http://docker-sync.io/).

Install `docker-sync`:

    $ brew install ruby && hash -r  # Do not install gems via system Ruby
    $ gem install docker-sync

Start sync services:

    $ docker-sync start  # Use `-f` to run in the foreground

**NOTE:** The first sync (and the first sync after `docker-sync clean`) can
take several minutes. Please be patient when it says `Looking for changes`.

Manage sync services:

    $ docker-sync clean  # Stop and clean up all sync points
    $ docker-sync logs   # Use `-f` to follow
    $ docker-sync stop
    $ docker-sync sync   # One time manual sync

### All platforms

Build a Docker image:

    $ docker-compose build --pull

Run an interactive project shell:

    $ docker-compose run --rm shell

**NOTE:** This will automatically start `celery`, `celerybeat`, `celeryflower`,
`elasticsearch`, `postgres` and `redis` as background services.

Manage background services:

    $ docker-compose logs [service ...]     # Use `-f` to follow
    $ docker-compose restart [service ...]
    $ docker-compose rm [service ...]       # Use `-v` to remove volumes
    $ docker-compose stop [service ...]
    $ docker-compose up [service ...]       # Use `-d` to run in the background


## Run an interactive project shell without Docker

Even when not running the project with Docker, it's still recommended to run
3rd party background services with Docker for isolation and version control:

    $ docker-compose run --rm -p 9200:9200 elasticsearch
    $ docker-compose run --rm -p 5432:5432 postgres
    $ docker-compose run --rm -p 6379:6379 redis

You can of course still run these natively, if you prefer.

Run an interactive project shell:

    $ ./go.sh

If this doesn't work, see [system requirements when running without docker](https://github.com/ixc/ixc-django-docker/#system-requirements-when-running-without-docker).


## About the interactive project shell

The interactive project shell provides a consistent way to run project commands
with and without Docker.

Run setup:

    (project_template) # setup.sh

This is equivalent to the following, each of which can be run independently:

    (project_template) # npm-install.sh
    (project_template) # bower-install.sh
    (project_template) # pip-install.sh
    (project_template) # setup-postgres.sh
    (project_template) # migrate.sh
    (project_template) # clear-cache.sh
    (project_template) # compile-sass.sh

Run management commands:

    (project_template) # manage.py createsuperuser
    (project_template) # manage.py search_index --rebuild
    (project_template) # manage.py shell_plus

Run services:

    (project_template) # celery.sh
    (project_template) # celerybeat.sh
    (project_template) # celeryflower.sh
    (project_template) # gunicorn.sh
    (project_template) # nginx.sh
    (project_template) # runserver.sh
    (project_template) # supervisor.sh

Get help:

    (project_template) # help.sh


## Compiling SASS/SCSS in the 'static' directory

Manually compile after making changes:

    (project_template) # compile-sass.sh

Detect changes and recompile automatically:

    (project_template) # compile-sass.sh --watch


## Updating Python requirements

Add pinned top level project dependencies to `requirements.in` and compile to
`requirements.txt`:

    (project_template) # pip-compile -v


## Testing

Run tests:

    (project_template) # runtests.sh

Default args are `.`, but you can override:

    (project_template) # runtests.sh --failfast .
    (project_template) # runtests.sh <path/to/tests>
    (project_template) # runtests.sh <dotted.path.to.tests>
    (project_template) # runtests.sh <dotted.path.to.tests:TestCase>

Update the test database dump after creating new migrations:

    (project_template) # setup-tests.sh pg_dump -f test_initial_data.sql -Ovx

Open a shell or run the dev server with test settings for manual testing:

    (project_template) # setup-tests.sh               # Open a shell
    (project_template) # setup-tests.sh runserver.sh  # Run the dev server

Run the tests exactly the same way that Codefresh does:

    $ docker-compose -f docker-compose.codefresh.yml build --pull        # Build image
    $ docker-compose -f docker-compose.codefresh.yml run --rm runtests   # Run tests
    $ docker-compose -f docker-compose.codefresh.yml stop                # Stop postgres and redis
    $ docker-compose -f docker-compose.codefresh.yml rm -v               # Remove containers and volumes
