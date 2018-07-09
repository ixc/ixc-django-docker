import setuptools

with open('README.rst') as f:
    long_description = f.read()

setuptools.setup(
    name='ixc-django-docker',
    use_scm_version={'version_scheme': 'post-release'},
    author='Interaction Consortium',
    author_email='studio@interaction.net.au',
    url='https://github.com/ic-labs/ixc-django-docker',
    description='Scripts and config files that make it easier to run Django '
                'projects consistently with and without Docker.',
    long_description=long_description,
    license='MIT',
    packages=setuptools.find_packages(),
    scripts=[
        'ixc_django_docker/bin/entrypoint.sh',
    ],
    include_package_data=True,
    install_requires=[
            'ConcurrentLogHandler',
            'coverage',
            'decorator',
            'Django',
            'django-split-settings',
            'gunicorn[gevent]',
            'jinja2',
            'python-redis-lock[django]',
    ],
    extras_require={
        'celery': [
            'celery[django]',
            'django-celery',
            'flower',
        ],
        'celery-email': [
            'django-celery-email',
        ],
        'compressor': [
            'django-compressor',
            'ixc-django-compressor',
        ],
        'datadog': [
            'ddtrace',
        ],
        'debug-toolbar': [
            'django-debug-toolbar',
        ],
        'extensions': [
            'django-extensions>=1.4.5',  # For `clear_cache` management command
        ],
        'haystack': [
            'django-haystack',
            'elasticsearch',  # For Elasticsearch 2.x
        ],
        'logentries': [
            'logentries',
        ],
        'master-password': [
            'django-master-password',
        ],
        'newrelic': [
            'newrelic',
        ],
        'nose': [
            'django-nose',
            'nose-exclude',
            'nose-progressive',
        ],
        'post-office': [
            'django-post-office',
        ],
        'postgres': [
            'psycopg2',
        ],
        'pydevd': [
            'pydevd',
        ],
        'sentry': [
            'raven',
        ],
        'storages': [
            'boto3',
            'django-storages',
        ],
        'whitenoise': [
            'ixc-whitenoise',
        ],
    },
    setup_requires=['setuptools_scm'],
)
