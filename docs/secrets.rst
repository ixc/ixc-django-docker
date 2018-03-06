Encrypted secrets
=================

Secrets should only be stored in ``.env.*.secret`` and ``docker-cloud.*.yml``
files, which must be encrypted by ``transcrypt`` or ``git-secret``.


Transcrypt (recommended)
------------------------

To enable, set the ``TRANSCRYPT_PASSWORD`` environment variable in
``.env.local`` and ``docker-cloud.*.yml`` files.

* Much simpler than ``git-secret`` in concept and implementation. Bash and
  OpenSSH are the only requirements.

* Needs only one password (no personal or other keys) to decrypt.

* Automated encryption and decryption via git attribute filters.

**WARNING:** Committing changes with a git client that does not support git
attribute filters makes it easy to accidentally commit unencrypted secrets.


Git-Secret (not recommended)
----------------------------

To enable, set the ``GPG_PASSPHRASE`` environment variable in ``.env.local`` and
``docker-cloud.*.yml`` files.

* Uses GPG for encryption, which can be painful, especially when running via
  ``go.sh``, as there are several version compatibility issues.

* Security model allows individual developers to have access granted or revoked
  by their personal keys. However, in an attempt to keep things simple, we
  ignore this feature and commit a single key directly to the repository,
  protected by a strong random passphrase.

* Stores encrypted files with a ``.secret`` file extension, and ignores the
  unencrypted version to ensure unencrypted secrets are never committed.

* Manual process to encrypt and decrypt files. Difficult to diff and stage
  individual hunks.

**TODO:** Remove this, if we don't recommend it?
