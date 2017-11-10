import os

# Create missing runtime directories.
runtime_dirs = STATICFILES_DIRS + (
    MEDIA_ROOT,
    os.path.join(PROJECT_DIR, 'templates'),
    os.path.join(VAR_DIR, 'logs'),
    # os.path.join(VAR_DIR, 'run'),
)
for dirname in runtime_dirs:
    try:
        os.makedirs(dirname)
    except OSError:
        pass
