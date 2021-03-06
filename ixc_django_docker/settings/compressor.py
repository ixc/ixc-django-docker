COMPRESS_CSS_FILTERS = (
    'compressor.filters.css_default.CssAbsoluteFilter',  # Default
    'compressor.filters.cssmin.rCSSMinFilter',
)

COMPRESS_OFFLINE_MANIFEST = os.path.join(
    os.environ.get('COMPRESS_OFFLINE_MANIFEST') or os.path.join(
        'manifest', '%s.json' % (os.environ.get('GIT_COMMIT') or '_unknown')
    )
)

# Offline compression is required when using WhiteNoise without autorefresh, which is
# not used in production because it is only intended for development and has had a
# serious security issue in the past.
COMPRESS_OFFLINE = True
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
