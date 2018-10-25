HIJACKED_EMAIL_BACKEND = EMAIL_BACKEND

EMAIL_BACKEND = 'ixc_django_docker.bandit.HijackedEmailBackend'

# Make it clear that the email has been hijacked and the environment frmo which
# it has originated.
EMAIL_SUBJECT_PREFIX = '[%s:%s] ' % (DOTENV.upper(), SITE_DOMAIN)

INSTALLED_APPS += ('bandit', )

# Make sure we are hijacking a backend that can actually send emails (e.g. to
# whitelisted recipients).
IXC_DJANGO_DOCKER_EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
