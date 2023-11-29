# Django <1.10 compatibility.
if django.VERSION < (1, 10):
    MIDDLEWARE_CLASSES = MIDDLEWARE

# Django <1.9 compatibility.
if django.VERSION < (1, 9):
    try:
        from django.utils.module_loading import import_path
    except ImportError:
        # Stolen from: https://github.com/django/django/blob/stable/1.7.x/django/utils/module_loading.py#L15-L33
        def import_string(dotted_path):
            """
            Import a dotted module path and return the attribute/class designated by the
            last name in the path. Raise ImportError if the import failed.
            """
            try:
                module_path, class_name = dotted_path.rsplit('.', 1)
            except ValueError:
                msg = "%s doesn't look like a module path" % dotted_path
                six.reraise(ImportError, ImportError(msg), sys.exc_info()[2])

            module = import_module(module_path)

            try:
                return getattr(module, class_name)
            except AttributeError:
                msg = 'Module "%s" does not define a "%s" attribute/class' % (
                    dotted_path, class_name)
                six.reraise(ImportError, ImportError(msg), sys.exc_info()[2])

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
