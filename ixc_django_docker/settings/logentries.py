import os

LOGGING['formatters']['logentries'] = {
    'format':
        '%(asctime)s '
        'level=%(levelname)s '
        'module=%(module)s '
        'function=%(funcName)s '
        'lineno=%(lineno)d '
        '%(message)s',
}

LOGGING['handlers']['logentries'] = {
    'class': 'logentries.LogentriesHandler',
    'formatter': 'logentries',
    'level': 'DEBUG',
    'token': os.environ.get('LOGENTRIES_TOKEN', ''),
}

LOGGING['loggers']['']['handlers'].append('logentries')
