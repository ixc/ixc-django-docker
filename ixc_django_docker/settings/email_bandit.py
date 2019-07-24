import os


# When loaded by django-split-settings __name__ gives us the *includer* file's
# name, not the name of this *included* file.
REAL_MODULE_NAME = ".".join([__package__, "email_bandit"])


# Hijack django-post-office backend if project is using that lib...
if 'POST_OFFICE' in locals():
    HIJACKED_EMAIL_BACKEND = POST_OFFICE['BACKENDS']['default']
    POST_OFFICE['BACKENDS']['default'] = \
        'ixc_django_docker.bandit.HijackedEmailBackend'
# ...otherwise hijack default Django backend
else:
    HIJACKED_EMAIL_BACKEND = EMAIL_BACKEND
    EMAIL_BACKEND = 'ixc_django_docker.bandit.HijackedEmailBackend'

# Hijack outgoing emails and send them to these email addresses instead.
# We will generally only use one email address, but multiple are supported.
# Specify envvar as a comma-delimited string, e.g.
#     BANDIT_EMAIL='admins@interaction.net.au'
if os.environ.get('BANDIT_EMAIL'):
    BANDIT_EMAIL = [
        email.strip()
        for email in os.environ['BANDIT_EMAIL'].split(',')
        if email.strip()
    ]
else:
    BANDIT_EMAIL = None
print("%s: BANDIT_EMAIL = %r" % (REAL_MODULE_NAME, BANDIT_EMAIL))

# Whitelist outgoing emails to these specific addresses or domains to let
# them through, instead of redirecting them to the BANDIT_EMAIL address.
# Specify envvar as a comma-delimited string, e.g.
#     BANDIT_WHITELIST='interaction.net.au,user_abc@client.org.au'
if os.environ.get('BANDIT_WHITELIST'):
    BANDIT_WHITELIST = [
        wl.strip()
        for wl in os.environ['BANDIT_WHITELIST'].split(',')
        if wl.strip()
    ]
else:
    BANDIT_WHITELIST = []
print("%s: BANDIT_WHITELIST = %r" % (REAL_MODULE_NAME, BANDIT_WHITELIST))

# Make it clear that emails have been hijacked and from which site.
# NOTE: This only applies to emails sent with admin-specific methods:
# https://docs.djangoproject.com/en/2.2/ref/settings/#email-subject-prefix
EMAIL_SUBJECT_PREFIX = '[hijacked:%s] ' % SITE_DOMAIN

INSTALLED_APPS += ('bandit', )

# Make sure we are hijacking a backend that can actually send emails (e.g. to
# whitelisted recipients).
IXC_DJANGO_DOCKER_EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
