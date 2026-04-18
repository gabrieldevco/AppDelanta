"""
URL configuration for config project.
"""
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/auth/', include('users.urls')),
    path('api/companies/', include('companies.urls')),
    path('api/advances/', include('advances.urls')),
    path('api/notifications/', include('notifications.urls')),
]
