import os

# Hijack django-post-office backend if project is using that lib...
if 'POST_OFFICE' in locals():
    HIJACKED_EMAIL_BACKEND = POST_OFFICE['BACKENDS']['default']
    POST_OFFICE['BACKENDS']['default'] = \
        'ixc_django_docker.bandit.HijackedEmailBackend'
# ...otherwise hijack default Django backend
else:
    HIJACKED_EMAIL_BACKEND = EMAIL_BACKEND
    EMAIL_BACKEND = 'ixc_django_docker.bandit.HijackedEmailBackend'

BANDIT_EMAIL = os.environ.get('BANDIT_EMAIL')

# Make it clear that emails have been hijacked and from which site.
# NOTE: This only applies to emails sent with admin-specific methods:
# https://docs.djangoproject.com/en/2.2/ref/settings/#email-subject-prefix
EMAIL_SUBJECT_PREFIX = '[hijacked:%s] ' % SITE_DOMAIN

INSTALLED_APPS += ('bandit', )

# Make sure we are hijacking a backend that can actually send emails (e.g. to
# whitelisted recipients).
IXC_DJANGO_DOCKER_EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
