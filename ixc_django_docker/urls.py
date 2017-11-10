from django.conf.urls import include, url
from django.contrib import admin
from django.views.generic import TemplateView

admin.autodiscover()

urlpatterns = [
    # Test error templates.
    url(r'^404/$', TemplateView.as_view(template_name='404.html')),
    url(r'^500/$', TemplateView.as_view(template_name='500.html')),
]

# Auto-include `project` URLs if they are available
try:
    from project import urls as project_urls
    urlpatterns += [
        url(r'^', include(project_urls)),
    ]
except ImportError:
    pass
