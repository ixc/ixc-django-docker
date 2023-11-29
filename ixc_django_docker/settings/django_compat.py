# Django <1.10 compatibility.
if django.VERSION < (1, 10):
    MIDDLEWARE_CLASSES = MIDDLEWARE

# Django <1.8 compatibility.
if django.VERSION < (1, 8):
    TEMPLATE_CONTEXT_PROCESSORS = [
        item.replace('django.core', 'django.template')
        for item in TEMPLATES[0]['OPTIONS']['context_processors']
    ]

    TEMPLATE_DIRS = TEMPLATES[0]['DIRS']
    TEMPLATE_LOADERS = TEMPLATES[0]['OPTIONS']['loaders']

    del MIDDLEWARE
    del TEMPLATES
