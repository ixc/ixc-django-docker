CELERY_EMAIL_BACKEND = EMAIL_BACKEND
EMAIL_BACKEND = 'djcelery_email.backends.CeleryEmailBackend'
INSTALLED_APPS += ('djcelery_email', )
