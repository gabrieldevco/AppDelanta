from django.db import models
from django.conf import settings


class Notification(models.Model):
    """Notificaciones del sistema"""
    
    TYPE_CHOICES = [
        ('info', 'Información'),
        ('success', 'Éxito'),
        ('warning', 'Advertencia'),
        ('error', 'Error'),
    ]
    
    # Destinatario
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='notifications',
        verbose_name='Usuario'
    )
    
    # Tipo y contenido
    type = models.CharField(
        max_length=20,
        choices=TYPE_CHOICES,
        default='info',
        verbose_name='Tipo'
    )
    title = models.CharField(
        max_length=255,
        verbose_name='Título'
    )
    message = models.TextField(
        verbose_name='Mensaje'
    )
    
    # Enlace opcional (para navegar desde la notificación)
    link = models.CharField(
        max_length=255,
        blank=True,
        verbose_name='Enlace'
    )
    
    # Estado
    is_read = models.BooleanField(
        default=False,
        verbose_name='¿Leída?'
    )
    read_at = models.DateTimeField(
        null=True,
        blank=True,
        verbose_name='Fecha de lectura'
    )
    
    # Relación con objetos (opcional)
    related_advance = models.ForeignKey(
        'advances.Advance',
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='notifications',
        verbose_name='Adelanto relacionado'
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'Notificación'
        verbose_name_plural = 'Notificaciones'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.title} - {self.user.get_full_name()}"
    
    def mark_as_read(self):
        """Marcar notificación como leída"""
        if not self.is_read:
            self.is_read = True
            self.read_at = models.DateTimeField(auto_now=True)
            self.save(update_fields=['is_read', 'read_at'])
    
    @property
    def time_ago(self):
        """Tiempo transcurrido desde la creación"""
        from django.utils import timezone
        from django.utils.timesince import timesince
        
        return timesince(self.created_at)


class SystemNotification(models.Model):
    """Notificaciones del sistema para administradores"""
    
    TYPE_CHOICES = [
        ('new_employer', 'Nuevo Empleador'),
        ('new_employee', 'Nuevo Empleado'),
        ('advance_request', 'Solicitud de Adelanto'),
        ('advance_approved', 'Adelanto Aprobado'),
        ('disbursement', 'Desembolso'),
        ('recovery', 'Recuperación'),
        ('system_alert', 'Alerta de Sistema'),
    ]
    
    type = models.CharField(
        max_length=30,
        choices=TYPE_CHOICES,
        verbose_name='Tipo'
    )
    title = models.CharField(
        max_length=255,
        verbose_name='Título'
    )
    message = models.TextField(
        verbose_name='Mensaje'
    )
    
    # Datos adicionales en JSON
    data = models.JSONField(
        default=dict,
        blank=True,
        verbose_name='Datos adicionales'
    )
    
    # Estado
    is_read = models.BooleanField(
        default=False,
        verbose_name='¿Leída?'
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'Notificación del Sistema'
        verbose_name_plural = 'Notificaciones del Sistema'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"[{self.get_type_display()}] {self.title}"
