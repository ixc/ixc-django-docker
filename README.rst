Run Django projects consistently with (and without) Docker
==========================================================

This project aims to:

* Make it easier to run Django projects consistently with (and without) Docker
  (for Mac/Windows, Cloud, etc.), in development and production environments.

* Solve issues relating to horizontal scaling and ephemeral infrastructure,
  where you have no persistent local storage and requests are handled by
  multiple servers in a load balanced configuration.

* Provide a migration path towards Docker for legacy projects.

* Get new projects up and running quickly with a consistent and familiar base
  to build from.

It includes:

* A reference Django project that *wraps* another Django project to provide
  sensible default settings plus many optional but commonly needed features.

* A *wrapped* Django project template that you can use as a starting point for
  new projects or when Dockerizing a legacy project.

* Composable settings modules. Use as many or as few as your project requires.

* Environment specific settings and encrypted secret management.

* Automation and configuration by convention via shell script wrappers and
  config file templates for commonly needed programs and tasks.

See the `documentation <https://github.com/ixc/ixc-django-docker/docs/index.md>`_
for more details.
