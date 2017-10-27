# Get host and port from the environment.
ELASTICSEARCH_ADDRESS = os.environ.get(
    'ELASTICSEARCH_ADDRESS', 'localhost:9200')

HAYSTACK_CONNECTIONS = {
    'default': {
        'ENGINE': 'icekit.utils.search.backends.ICEkitConfigurableElasticSearchEngine',
        'INDEX_NAME': 'haystack-%s' % PROJECT_SLUG,
        'URL': 'http://%s/' % ELASTICSEARCH_ADDRESS,
    },
}

HAYSTACK_SIGNAL_PROCESSOR = 'haystack.signals.BaseSignalProcessor'
INSTALLED_APPS += ('haystack', )
