import contextlib
import os
import posixpath
import shutil
import tempfile

import requests
from django.conf import settings
from django.core.files.storage import FileSystemStorage, default_storage
from django.utils.functional import LazyObject
from ixc_whitenoise.storage import UniqueMixin, UniqueStorage, unlazy_storage
from storages.backends.s3boto3 import S3Boto3Storage

from ixc_django_docker import appsettings


@contextlib.contextmanager
def get_local_file_path(file_obj, keep=False):
    """
    Yield a file object's path if possible, or copy its content to the local
    filesystem and yield its path.

    If `keep=False`, a temporary file is used and deleted on exit. Otherwise,
    the local file is kept so that future requests can skip the download.

    Useful when you need to access files from remote storage outside of Python.
    """
    try:
        # The file is already local. Yield its path.
        yield file_obj.path
    except NotImplementedError:
        # Copy file content into a named temporary file, so we can access it
        # from a subprocess.
        if keep:
            name = os.path.join(
                settings.VAR_DIR,
                'local-files',
                type(unlazy_storage(file_obj.storage)).__name__,
                file_obj.name,
            )
            if not os.path.exists(name):
                try:
                    os.path.makedirs(os.path.dirname(name))
                except:
                    pass
                with open(name, 'w+b') as local_file:
                    shutil.copyfileobj(file_obj, local_file)
            yield name
        else:
            with tempfile.NamedTemporaryFile() as local_file:
                shutil.copyfileobj(file_obj, local_file)
                yield local_file.name


# MIXINS ######################################################################


class S3GetContentHashMixin(object):

    def get_content_hash(self, name):
        """
        Get hash from Etag header to avoid downloading content.
        """
        response = requests.head(
            self.bucket.meta.client.generate_presigned_url(
                'head_object', Params={
                    'Bucket': self.bucket.name,
                    'Key': posixpath.join(self.location, name),
                }))
        # Strip the double quotes included in the Etag header returned by S3.
        # Return `None` when no Etag is available.
        content_hash = response.headers.get('Etag', '').strip('"') or None
        return content_hash


class S3MediaLocationMixin(object):
    """
    Pass `settings.MEDIA_URL` (stripped of leading and trailing slashes) as the
    `location` argument to the init method.
    """

    def __init__(self, *args, **kwargs):
        kwargs.setdefault('location', settings.MEDIA_URL.strip('/'))
        super(S3MediaLocationMixin, self).__init__(*args, **kwargs)


class S3PrivateMixin(object):
    """
    Enable querystring auth and use `private` as default ACL.
    """

    def __init__(self, *args, **kwargs):
        kwargs.setdefault('default_acl', 'private')
        kwargs.setdefault('querystring_auth', True)
        super(S3PrivateMixin, self).__init__(*args, **kwargs)


class S3PublicMixin(object):
    """
    Disable querystring auth and use `public-read` as default ACL.
    """

    def __init__(self, *args, **kwargs):
        kwargs.setdefault('default_acl', 'public-read')
        kwargs.setdefault('querystring_auth', False)
        super(S3PublicMixin, self).__init__(*args, **kwargs)


class S3StaticLocationMixin(object):
    """
    Pass `settings.STATIC_URL` (stripped of leading and trailing slashes) as
    the `location` argument to the init method.
    """

    def __init__(self, *args, **kwargs):
        kwargs.setdefault('location', settings.STATIC_URL.strip('/'))
        super(S3StaticLocationMixin, self).__init__(*args, **kwargs)


# STORAGE CLASSES #############################################################


class S3PrivateStorage(S3MediaLocationMixin, S3PrivateMixin, S3Boto3Storage):
    pass


class S3PublicStorage(S3MediaLocationMixin, S3PublicMixin, S3Boto3Storage):
    pass


class S3UniquePrivateStorage(
        UniqueMixin,
        S3GetContentHashMixin,
        S3MediaLocationMixin,
        S3PrivateMixin,
        S3Boto3Storage):
    pass


class S3UniquePublicStorage(
        UniqueMixin,
        S3GetContentHashMixin,
        S3MediaLocationMixin,
        S3PublicMixin,
        S3Boto3Storage):
    pass


# LAZY STORAGE CLASSES ########################################################


class PrivateStorage(LazyObject):

    def _setup(self):
        if appsettings.ENABLE_UNIQUE_STORAGE:
            if appsettings.ENABLE_S3_STORAGE:
                self._wrapped = S3UniquePrivateStorage()
            else:
                raise NotImplemented(
                    'Local unique private storage is not available, yet.')
        else:
            if appsettings.ENABLE_S3_STORAGE:
                self._wrapped = S3PrivateStorage()
            else:
                raise NotImplemented(
                    'Local private storage is not available, yet.')


class PublicStorage(LazyObject):

    def _setup(self):
        if appsettings.ENABLE_UNIQUE_STORAGE:
            if appsettings.ENABLE_S3_STORAGE:
                self._wrapped = S3UniquePublicStorage()
            else:
                self._wrapped = UniqueStorage()
        else:
            if appsettings.ENABLE_S3_STORAGE:
                self._wrapped = S3PublicStorage()
            else:
                self._wrapped = FileSystemStorage()


class ThumbnailStorage(LazyObject):
    """
    Never use unique storage for thumbnails.
    """

    # TODO: Allow private thumbnail storage for objects using private storage.
    # Perhaps by naming objects with a `private/` prefix.

    def _setup(self):
        if appsettings.ENABLE_S3_STORAGE:
            self._wrapped = S3PublicStorage()
        else:
            self._wrapped = FileSystemStorage()


# STORAGE OBJECTS #############################################################


private_storage = PrivateStorage()
public_storage = PublicStorage()
thumbnail_storage = ThumbnailStorage()
