Encrypted secrets
=================

Secrets should only be stored in ``*.secret*`` files, which must be encrypted by
``transcrypt``.


Transcrypt
----------

Automated encryption and decryption via git attribute filters.

To enable, set the ``TRANSCRYPT_PASSWORD`` environment variable in
``.env.local`` and Docker stack files.

**WARNING**

Committing changes with a git client that does not support git
attribute filters makes it easy to accidentally commit unencrypted secrets.

To make absolutely sure that files you are about to push have been
transparently encrypted, disable git's text conversion processing of
`.gitattributes` settings when viewing git log patches to confirm that secret
files are listed as binary diffs, not the usual plain text diffs::

     git log --patch --no-textconv
