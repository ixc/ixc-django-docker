AUTHENTICATION_BACKENDS += ('master_password.auth.ModelBackend', )
INSTALLED_APPS += ('master_password', )
MASTER_PASSWORD = os.environ.get('MASTER_PASSWORD')

if MASTER_PASSWORD:
    MASTER_PASSWORDS = {MASTER_PASSWORD: None}
