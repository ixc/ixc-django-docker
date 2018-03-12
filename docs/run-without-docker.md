Run without Docker
==================

With `go.sh`, you can run a project in a native environment that is configured
in such a way that our shell scripts and project config works much as they
would under Docker.

This generally performs much better than with Docker, but you need to manage
service dependencies manually.

However, you can still run those service dependencies via Docker, and as long as
they don't use an `osxfs` shared volume, performance should be acceptable.


Getting started
===============

Start any required services:

    $ docker-compose up -d elasticsearch postgres redis

Or:

    $ brew services start elasticsearch@2.4
    $ brew services start postgres
    $ brew services start redis

Open an interactive shell:

    $ ./go.sh

Manually start individual services from the interactive shell:

    (PROJECT_NAME)$ celery.sh
    (PROJECT_NAME)$ celerybeat.sh
    (PROJECT_NAME)$ celeryflower.sh
    (PROJECT_NAME)$ manage.py [COMMAND [ARGS]]
    (PROJECT_NAME)$ migrate.sh
    (PROJECT_NAME)$ pydevd.sh <COMMAND>
    (PROJECT_NAME)$ runserver.sh [ARGS]
    (PROJECT_NAME)$ runtests.sh [ARGS]

**NOTE:** These are just the most commonly used [commands](commands.md).

When you're done, exit the interactive shell and stop all services:

    $ docker-compose stop

Or:

    $ brew services stop elasticsearch@2.4
    $ brew services stop postgres
    $ brew services stop redis


System requirements
===================

* md5sum
* Nginx
* NPM
* Pipe Viewer
* PostgreSQL
* Python 2.7
* Redis
* Yarn

Optional:

* [Elasticsearch](https://www.elastic.co/products/elasticsearch) 2.x (5.x is
  not compatible with `django-haystack`)
* [Git Secret](https://github.com/sobolevn/git-secret) (not recommended)
* [Transcrypt](https://github.com/elasticdog/transcrypt)


macOS
-----

Install Xcode command line tools:

    $ xcode-select --install

Install [Homebrew](http://brew.sh/):

    $ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

Install [Postgres.app](http://postgresapp.com/).

Install required system packages:

    $ brew install md5sha1sum nginx npm pv python redis yarn

Install optional system packages:

    $ brew install elasticsearch@2.4
    $ brew link elasticsearch@2.4 --force
    $ brew install git-secret
    $ brew install transcrypt
