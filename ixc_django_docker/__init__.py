import os

# Connect to remote debug server if environment is configured.
if os.environ.get('PYDEVD') and os.environ.get('RUN_MAIN') == 'true':
    import pydevd
    pydevd.settrace(
        host=os.environ.get('PYDEVD_HOST', 'localhost'),
        port=os.environ.get('PYDEVD_PORT', 5678),
        stdoutToServer=True,
        stderrToServer=True,
        suspend=False,  # Don't emulate a breakpoint when called
    )
