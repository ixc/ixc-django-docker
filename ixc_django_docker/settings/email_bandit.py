import os

from django.conf import settings


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

# Print the additional emails whitelisted by Bandit by default, to make it
# clearer that this is what Bandit does. See logic in
# `bandit.backends.base:HijackBackendMixin.send_messages()`
admin_emails = [email for name, email in getattr(settings, 'ADMINS', [])]
server_email = getattr(settings, 'SERVER_EMAIL', 'root@localhost')
extra_whitelisted = admin_emails + [server_email]
print(
    "%s: Emails automatically whitelisted by Bandit, from `settings.ADMINS` and"
    " `settings.SERVER_EMAIL` = %r" % (REAL_MODULE_NAME, extra_whitelisted)
)

# Ensure that BANDIT_EMAIL is set appropriately: it is always required and
# must contain at least one value
if not BANDIT_EMAIL:
    raise ValueError(
        "BANDIT_EMAIL environment variable must be set with at least one"
        " email address. If you do not want to hijack email, remove"
        " 'email_bandit.py' from the BASE_SETTINGS environment variable")

# Make it clear that emails have been hijacked and from which site.
# NOTE: This only applies to emails sent with admin-specific methods:
# https://docs.djangoproject.com/en/2.2/ref/settings/#email-subject-prefix
EMAIL_SUBJECT_PREFIX = '[hijacked:%s] ' % SITE_DOMAIN

INSTALLED_APPS += ('bandit', )

# Make sure we are hijacking a backend that can actually send emails (e.g. to
# whitelisted recipients).
IXC_DJANGO_DOCKER_EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
