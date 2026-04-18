from django.contrib import admin
from .models import Notification, SystemNotification


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ['title', 'user', 'type', 'is_read', 'created_at']
    list_filter = ['type', 'is_read', 'created_at']
    search_fields = ['title', 'message', 'user__email', 'user__first_name', 'user__last_name']
    autocomplete_fields = ['user', 'related_advance']
    readonly_fields = ['created_at']
    
    fieldsets = (
        ('Destinatario', {
            'fields': ('user',)
        }),
        ('Contenido', {
            'fields': ('type', 'title', 'message', 'link')
        }),
        ('Relación', {
            'fields': ('related_advance',)
        }),
        ('Estado', {
            'fields': ('is_read', 'read_at', 'created_at')
        }),
    )


@admin.register(SystemNotification)
class SystemNotificationAdmin(admin.ModelAdmin):
    list_display = ['type', 'title', 'is_read', 'created_at']
    list_filter = ['type', 'is_read', 'created_at']
    search_fields = ['title', 'message']
    readonly_fields = ['created_at']
