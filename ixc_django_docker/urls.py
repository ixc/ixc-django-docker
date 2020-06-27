from importlib import import_module
import os

from django.conf import settings
from django.conf.urls import include, url
from django.contrib import admin
from django.core.exceptions import ImproperlyConfigured
from django.views.generic import TemplateView

admin.autodiscover()

urlpatterns = [
    # Test error templates.
    url(r'^404/$', TemplateView.as_view(template_name='404.html')),
    url(r'^500/$', TemplateView.as_view(template_name='500.html')),
]

# Django Debug Toolbar.
if 'debug_toolbar' in settings.INSTALLED_APPS:
    import debug_toolbar
    urlpatterns += [
        url(r'^__debug__/', include(debug_toolbar.urls)),
    ]

# Auto-include `project` URLs if they are available
checked = []
for module in (
    os.environ.get('PROJECT_URLCONF'),
    'djangosite.urls',
    'project_urls',
):
    if module:
        checked.append("'%s'" % module)
        try:
            project_urlconf = import_module(module)
        except ImportError:
            continue
        break
else:
    raise ImproperlyConfigured(
        'No project urlconf found. Checked: ' + ', '.join(checked)
    )
urlpatterns += [
    url(r'^', include(project_urlconf)),
]
