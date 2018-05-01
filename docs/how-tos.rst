How to run a remote debug server with `pydevd` (e.g. PyCharm)
=============================================================

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


How to dockerize an existing project
====================================

* Update project requirements:

  * Rename ``requirements.txt`` to ``requirements.in`` and trim the contents down
  to only the specific project requirements you need to specify; the rest of
  the project requirements will be populated into ``requirements.txt`` by
  ``pip-compile``

    The ``setup.py`` file is a good place to look for the fundamental project-specific requirements.

  * Include in ``requirements.in`` a reference to this project along with all the
  supporting features you will use, for example::

    ixc-django-docker[postgres,sentry,whitenoise,storages,compressor,celery,celery-email]

  * Use ``pip-compile -v`` (from the ``pip-tools`` library) to regenerate
    ``requirements.txt`` from the new ``requirements.in`` file. Check a diff of
    this file carefully to make sure the requirements still look complete and
    accurate, and adjust ``requirements.in`` as necessary to make this the case.

  * Commit your changes to the requirements files

* Add to -- or update all files in -- your project directory with changes from the
  corresponding files in the ``project_template`` directory::

    # From your project's dir, assuming a checkout of ixc-django-docker in ../
    cp ../ixc-django-docker/project_template/* .
    cp ../ixc-django-docker/project_template/.* .

  * Replace occurrences of ``project_template`` in these copied files with your
    project name.
  * Carefully check all the added and (especially) changed files to make sure
    the changes look okay -- this is something of a black art. Undo unwanted
    changes but keep as much as you can

* Configure environment variables

  * Create an ``.env.local`` file and set at least the ``DOTENV`` and
    ``TRANSCRYPT_PASSWORD`` variables

  * Add ``.env.{FOO}`` and ``docker-cloud.{FOO}.yml`` for each environment.
    These may contain secrets, and must not be committed to the repository
    unencrypted. See [About secrets], above.

* Test the local ``./go.sh`` environment:

  * Make ``go.sh`` executable::

    $ chmod 755 go.sh

  * Delete ``manage.py`` from your project. This is now installed into your
  virtualenv bin directory by ``ixc-django-docker``.

  * Run ``./go.sh`` to set up your local development environment, fix any
    problem with creating it, and confirm it works with some basic testing of
    ``runserver.sh`` and ``runtests.sh`` etc.

* If you are updating an existing older *ixc-django-docker* project or one of
  its forerunners, you should check for scripts in the ``bin/`` directory and
  remove any that will override the updated versions now available in
  *ixc-django-docker*

* Prepare project data and media files

  * Add a production database dump named ``initial_data.sql`` to your project
  directory.

      This allows us to avoid running migrations from scratch, which often does not
  work with older projects, and saves us time even when migrations do work.

  * Use the AWS CLI to sync the production media directory to a new S3 bucket::

    $ pip install awscli
    $ AWS_ACCESS_KEY_ID='' AWS_SECRET_ACCESS_KEY='' AWS_DEFAULT_REGION='us-west-2' aws s3 sync {path/to/media} s3://{bucket-name}/media/ > aws-s3-sync.log 2>&1 & tail -f aws-s3-sync.log

* Update project settings. See [About settings modules], above.
