AWS_ACCESS_KEY_ID = os.environ.get('MEDIA_AWS_ACCESS_KEY_ID')

# See: http://developer.yahoo.com/performance/rules.html#expires
AWS_HEADERS = {
    'Expires': 'Thu, 31 Dec 2099 00:00:00 GMT',
    'Cache-Control': 'max-age=86400',
}

AWS_SECRET_ACCESS_KEY = os.environ.get('MEDIA_AWS_SECRET_ACCESS_KEY')

AWS_STORAGE_BUCKET_NAME = os.environ.get(
    'MEDIA_AWS_STORAGE_BUCKET_NAME', PROJECT_SLUG)

ENABLE_S3_STORAGE = True

INSTALLED_APPS += ('storages', )
