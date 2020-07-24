COMPRESS_CSS_FILTERS = (
    'compressor.filters.css_default.CssAbsoluteFilter',  # Default
    'compressor.filters.cssmin.rCSSMinFilter',
)

# Offline compression only is needed when there is no persistent shared volume for all
# gunicorn processes (e.g. Docker Swarm) OR when using WhiteNoise without autorefresh.
COMPRESS_OFFLINE = False
COMPRESS_OFFLINE_CONTEXT = 'ixc_compressor.get_compress_offline_context'

COMPRESS_PRECOMPILERS = (
    (
        'text/less',
        '"%s" {infile} {outfile} --autoprefix' % (
            os.path.join(PROJECT_DIR, 'node_modules', '.bin', 'lessc'),
        ),
    ),
)

INSTALLED_APPS += ('compressor', )
STATICFILES_FINDERS += ('compressor.finders.CompressorFinder', )

# Whether or not to include a fake `Request` in the global context.
# IXC_COMPRESSOR_REQUEST = False  # Default: True

# A sequence of key/value tuples to be included in every generated context.
IXC_COMPRESSOR_GLOBAL_CONTEXT = ()

# A sequence of key/value tuples, every combination of which will be combined
# with the global context when generating contexts.
IXC_COMPRESSOR_OPTIONAL_CONTEXT = ()
