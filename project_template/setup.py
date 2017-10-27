# This file exists so we can ``pip install -e .`` to add the project directory
# to the Python path.

import datetime
import setuptools

setuptools.setup(
    name='project_template',
    version='0+d%s' % datetime.date.today().strftime('%Y%m%d'),
)
