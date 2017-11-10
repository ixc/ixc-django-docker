# Actually send emails.
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'

# Keep more log backups. Enable LogEntries log handler.
LOGGING['handlers']['logfile']['backupCount'] = 100
LOGGING['loggers']['']['handlers'].append('logentries')

# Enable the per-site cache.
MIDDLEWARE_CLASSES = \
    ('django.middleware.cache.UpdateCacheMiddleware', ) + \
    MIDDLEWARE_CLASSES + \
    ('django.middleware.cache.FetchFromCacheMiddleware', )

# Enable the cached template loader.
TEMPLATES[0]['OPTIONS']['loaders'] = [
    (
        'django.template.loaders.cached.Loader',
        TEMPLATES[0]['OPTIONS']['loaders'],
    ),
]
