INSTALLED_APPS += ('post_office', )

POST_OFFICE = {
    'BACKENDS': {
        'default': EMAIL_BACKEND,
    },
    'DEFAULT_PRIORITY': 'now',
}

EMAIL_BACKEND = 'post_office.EmailBackend'
