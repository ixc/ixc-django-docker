# Keep more log backups.
LOGGING['handlers']['logfile']['backupCount'] = 100

# Enable the per-site cache.
MIDDLEWARE = (
    ('django.middleware.cache.UpdateCacheMiddleware', ) +
    MIDDLEWARE +
    ('django.middleware.cache.FetchFromCacheMiddleware', )
)

# Enable the cached template loader.
TEMPLATES[0]['OPTIONS']['loaders'] = [
    (
        'django.template.loaders.cached.Loader',
        TEMPLATES[0]['OPTIONS']['loaders'],
    ),
]
