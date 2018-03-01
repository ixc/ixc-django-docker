# Keep more log backups. Enable LogEntries log handler.
LOGGING['handlers']['logfile']['backupCount'] = 100
LOGGING['loggers']['']['handlers'].append('logentries')

# Enable the per-site cache.
if django.VERSION < (1, 10):
    MIDDLEWARE_CLASSES = \
        ('django.middleware.cache.UpdateCacheMiddleware', ) + \
        MIDDLEWARE_CLASSES + \
        ('django.middleware.cache.FetchFromCacheMiddleware', )
else:
    MIDDLEWARE = \
        ('django.middleware.cache.UpdateCacheMiddleware', ) + \
        MIDDLEWARE + \
        ('django.middleware.cache.FetchFromCacheMiddleware', )

# Enable the cached template loader.
TEMPLATES[0]['OPTIONS']['loaders'] = [
    (
        'django.template.loaders.cached.Loader',
        TEMPLATES[0]['OPTIONS']['loaders'],
    ),
]
