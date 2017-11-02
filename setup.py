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
        'ixc_django_docker/bin/cronlock.sh',
        'ixc_django_docker/bin/entrypoint.sh',
        'ixc_django_docker/bin/gunicorn.sh',
        'ixc_django_docker/bin/help.sh',
        'ixc_django_docker/bin/manage.py',
        'ixc_django_docker/bin/migrate.sh',
        'ixc_django_docker/bin/nginx.sh',
        'ixc_django_docker/bin/npm-install.sh',
        'ixc_django_docker/bin/pip-install.sh',
        'ixc_django_docker/bin/runserver.sh',
        'ixc_django_docker/bin/runtests.sh',
        'ixc_django_docker/bin/setup-django.sh',
        'ixc_django_docker/bin/setup-git-secret.sh',
        'ixc_django_docker/bin/setup-postgres.sh',
        'ixc_django_docker/bin/setup-tests.sh',
        'ixc_django_docker/bin/supervisor.sh',
        'ixc_django_docker/bin/transfer.sh',
        'ixc_django_docker/bin/waitlock.sh',
    ],
    include_package_data=True,
    install_requires=[
        'ConcurrentLogHandler',
        'django-compressor',
        'django-extensions',
        'django-split-settings',
        'django-storages',
        'Django',
        'ixc-django-compressor',
        'ixc-whitenoise',
        'logentries',
    ],
    extras_require={
        'project_template': [
            'celery[django]',
            'django-celery',
            'django-celery-email',
            'django-haystack',
            'django-master-password',
            'django-nose',
            'django-post-office',
            'psycopg2',
            'python-redis-lock[django]',
        ],
    },
    setup_requires=['setuptools_scm'],
)
