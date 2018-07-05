Common horizontal scaling and ephemeral infrastructure issues and solutions
===========================================================================

These are the critical issues that can arise when running a Django project with
Docker on ephemeral infrastructure, that ``ixc-django-docker`` aims to solve:

* Compress CSS, JavaScript, Less, Sass, etc. offline, so each container in a
  multi-node configuration has immediate access to all compressed assets.

  In-request compression does not work in a multi-node configuration, without
  a shared persistent volume, because the container doing the compression may
  not be the one that receives the request for compressed assets.

* Use host names instead of ``localhost`` for services, e.g. ElasticSearch,
  PostgreSQL, Redis, etc.

* Use a service like `LogEntries <https://logentries.com>`__ to avoid data loss
  when ephemeral nodes are terminated. As a bonus, aggregators make log analysis
  much easier.

* Disable anything in the base settings module that triggers a connection
  attempt to a remote service, which will not be available when building Docker
  images.

  For example, ``manage.py compress`` will attempt to connect to the configured
  cache backend.

* Use AWS S3 remote storage for uploaded media. Containers run on ephemeral
  nodes that may disappear at any time. In a multi-node configuration, all nodes
  need access to media.

* Use ``whitenoise`` to efficiently serve compressed and uniquely named static
  files and media that can be cached forever.

* Secret management. You don't want to store unencrypted secrets in a Docker
  image or Git repository.

**TODO:** Use a CDN (e.g. Cloudfront) in front of ``whitenoise``.

**TODO:** Move this section to the top of this document?
