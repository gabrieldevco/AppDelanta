from rest_framework import serializers
from .models import Notification, SystemNotification


class NotificationSerializer(serializers.ModelSerializer):
    """Serializer para notificaciones de usuario"""
    type_display = serializers.CharField(source='get_type_display', read_only=True)
    time_ago = serializers.CharField(read_only=True)
    
    class Meta:
        model = Notification
        fields = ['id', 'type', 'type_display', 'title', 'message', 'link',
                  'is_read', 'read_at', 'created_at', 'time_ago',
                  'related_advance']
        read_only_fields = ['id', 'created_at', 'time_ago']


class SystemNotificationSerializer(serializers.ModelSerializer):
    """Serializer para notificaciones del sistema"""
    type_display = serializers.CharField(source='get_type_display', read_only=True)
    
    class Meta:
        model = SystemNotification
        fields = ['id', 'type', 'type_display', 'title', 'message', 'data',
                  'is_read', 'created_at']
        read_only_fields = ['id', 'created_at']


class NotificationMarkReadSerializer(serializers.Serializer):
    """Serializer para marcar notificaciones como leídas"""
    notification_ids = serializers.ListField(
        child=serializers.IntegerField(),
        required=False
    )
    mark_all = serializers.BooleanField(default=False)
