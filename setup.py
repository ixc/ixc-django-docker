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
        'ixc_django_docker/bin/bash.sh',
        'ixc_django_docker/bin/bower-install.sh',
        'ixc_django_docker/bin/celery.sh',
        'ixc_django_docker/bin/celerybeat.sh',
        'ixc_django_docker/bin/celeryflower.sh',
        'ixc_django_docker/bin/clear-cache.sh',
        'ixc_django_docker/bin/entrypoint.sh',
        'ixc_django_docker/bin/gunicorn.sh',
        'ixc_django_docker/bin/help.sh',
        'ixc_django_docker/bin/logentries.sh',
        'ixc_django_docker/bin/manage.py',
        'ixc_django_docker/bin/migrate.sh',
        'ixc_django_docker/bin/newrelic.sh',
        'ixc_django_docker/bin/nginx.sh',
        'ixc_django_docker/bin/npm-install.sh',
        'ixc_django_docker/bin/pip-install.sh',
        'ixc_django_docker/bin/pydevd.sh',
        'ixc_django_docker/bin/redis-cache.py',
        'ixc_django_docker/bin/runserver.sh',
        'ixc_django_docker/bin/runtests.sh',
        'ixc_django_docker/bin/setup-django.sh',
        'ixc_django_docker/bin/setup-git-secret.sh',
        'ixc_django_docker/bin/setup-postgres.sh',
        'ixc_django_docker/bin/setup-tests.sh',
        'ixc_django_docker/bin/supervisor.sh',
        'ixc_django_docker/bin/transcrypt',
        'ixc_django_docker/bin/transfer.sh',
        'ixc_django_docker/bin/waitlock.py',
    ],
    include_package_data=True,
    install_requires=[
            'ConcurrentLogHandler',
            'coverage',
            'decorator',
            'Django',
            'django-split-settings',
            'gunicorn',
            'jinja2',
            'python-redis-lock[django]',
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
        'debug-toolbar': [
            'django-debug-toolbar',
        ],
        'extensions': [
            'django-extensions',
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
