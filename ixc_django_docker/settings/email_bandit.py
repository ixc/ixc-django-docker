HIJACKED_EMAIL_BACKEND = EMAIL_BACKEND

EMAIL_BACKEND = 'ixc_django_docker.bandit.HijackedEmailBackend'
INSTALLED_APPS += ('bandit', )

# Make sure we are hijacking a backend that can actually send emails (e.g. to
# whitelisted recipients).
IXC_DJANGO_DOCKER_EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
