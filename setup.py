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
            'concurrent-log-handler',
            'coverage',
            'decorator',
            'Django',
            'django-split-settings',
            'futures; python_version == "2.7"',
            'gunicorn[gevent]>=19.8.0',  # Extra was added in 19.8.0
            'jinja2',
            'python-redis-lock[django]',
            'six',
    ],
    extras_require={
        'celery': [
            'celery[django]',
            'flower',
        ],
        'celery3': [
            'django-celery',
        ],
        'celery4': [
            'django-celery-beat',
            'django-celery-results',
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
        'email-bandit': [
            'django-email-bandit',
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
            # Temporarily disabled until nose-progressive adds support for setuptools>=58
            #'nose-progressive',
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
            'requests',
        ],
        'whitenoise': [
            'ixc-whitenoise',
        ],
    },
    setup_requires=['setuptools_scm'],
)
