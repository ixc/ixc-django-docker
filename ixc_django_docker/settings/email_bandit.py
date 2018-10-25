import os

HIJACKED_EMAIL_BACKEND = EMAIL_BACKEND

BANDIT_EMAIL = os.environ.get('BANDIT_EMAIL')
EMAIL_BACKEND = 'ixc_django_docker.bandit.HijackedEmailBackend'

# Make it clear that emails have been hijacked and from which site.
EMAIL_SUBJECT_PREFIX = '[hijacked:%s] ' % SITE_DOMAIN

INSTALLED_APPS += ('bandit', )

# Make sure we are hijacking a backend that can actually send emails (e.g. to
# whitelisted recipients).
IXC_DJANGO_DOCKER_EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
