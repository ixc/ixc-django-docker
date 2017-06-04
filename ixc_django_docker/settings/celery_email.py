CELERY_EMAIL_BACKEND = EMAIL_BACKEND
INSTALLED_APPS += ('djcelery_email', )

EMAIL_BACKEND = 'djcelery_email.backends.CeleryEmailBackend'
