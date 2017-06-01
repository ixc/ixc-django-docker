from django.conf import settings


def environment(request=None):
    """
    Return any settings listed in ``CONTEXT_PROCESSOR_SETTINGS`` as context,
    plus any additional context returned by `project.context_processors.environment`.
    """
    context = {
    }

    for key in getattr(settings, 'CONTEXT_PROCESSOR_SETTINGS', []):
        context[key] = getattr(settings, key, None)

    try:
        from project.context_processors import environment
        context.update(environment(request))
    except ImportError:
        pass

    return context
