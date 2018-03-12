Encrypted secrets
=================

Secrets should only be committed in `*.secret*` files, which are automatically
encrypted via [Transcrypt](https://github.com/elasticdog/transcrypt) when
staged, and automatically decrypted on checkout.

To initialize your working copy, set the `TRANSCRYPT_PASSWORD` environment
variable in `.env.local` or `docker-cloud.yml`, then run the project.

**WARNING:** Git GUI support for attribute filters (required by Transcrypt) is
minimal or non-existent. Always checkout and stage secrets via Git CLI.

**IMPORTANT:** You cannot stage individual hunks in encrypted files. Try to
make atomic changes and commit early/often with descriptive commit messages
when updating encrypted secrets.


Git Secret (not recommended)
============================

We previously recommended [Git Secret](https://github.com/sobolevn/git-secret)
instead of Transcrypt, and some older projects might still be using it.

We now recommend updating these projects to use Transcrypt, primarily because
Transcrypt is simpler in concept and implementation, and Git Secret relies on
GnuPG which has several backwards compatibility issues between Linux and macOS.

How to switch
-------------

Set `TRANSCRYPT_PASSWORD` to `GPG_PASSPHRASE` in `.env.local` and
`docker-cloud.*.yml` files, and your current shell:

    $ export TRANSCRYPT_PASSWORD="$GPG_PASSPHRASE"

Decrypt then remove encrypted secrets and config:

    $ git secret reveal
    $ git rm .gitsecret .gnupg
    $ find . -name '*.secret*' -exec git rm "{}" +

Manually rename the decrypted `*.secret*` files to include `.secret` in their
name and stage them:

    $ mv .env.FOO .env.FOO.secret
    $ mv docker-cloud.FOO.yml docker-cloud.FOO.secret.yml
    $ find . -name '*.secret*' -exec git add "{}" +

Configure Transcrypt and initialize the repository (once per working copy):

    $ echo '*.secret* filter=crypt diff=crypt' >> .gitattributes
    $ git add .gitattributes
    $ transcrypt -c aes-256-cbc -p "$TRANSCRYPT_PASSWORD"

**WARNING:** Git Secret decrypts files to a different filename, without a
`.secret` extension. Transcrypt decrypts files in-place. Any attempt to access
`FOO` in your code should now access `FOO.secret`, instead.
