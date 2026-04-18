from django.db import models
from django.conf import settings


class Advance(models.Model):
    """Solicitud de adelanto de nómina"""
    
    STATUS_CHOICES = [
        ('pending', 'Pendiente'),
        ('approved', 'Aprobado'),
        ('rejected', 'Rechazado'),
        ('disbursed', 'Desembolsado'),
        ('recovered', 'Recuperado'),
        ('cancelled', 'Cancelado'),
    ]
    
    # Relaciones
    employee = models.ForeignKey(
        'users.EmployeeProfile',
        on_delete=models.CASCADE,
        related_name='advances',
        verbose_name='Empleado'
    )
    company = models.ForeignKey(
        'companies.Company',
        on_delete=models.CASCADE,
        related_name='advances',
        verbose_name='Empresa'
    )
    
    # Montos
    amount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        verbose_name='Monto solicitado'
    )
    fee = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=0,
        verbose_name='Comisión'
    )
    total_amount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        verbose_name='Monto total'
    )
    
    # Estado
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='pending',
        verbose_name='Estado'
    )
    
    # Motivo
    reason = models.TextField(
        blank=True,
        verbose_name='Motivo de la solicitud'
    )
    
    # Fechas
    request_date = models.DateTimeField(
        auto_now_add=True,
        verbose_name='Fecha de solicitud'
    )
    approved_at = models.DateTimeField(
        null=True,
        blank=True,
        verbose_name='Fecha de aprobación'
    )
    disbursed_at = models.DateTimeField(
        null=True,
        blank=True,
        verbose_name='Fecha de desembolso'
    )
    recovery_date = models.DateField(
        null=True,
        blank=True,
        verbose_name='Fecha de recuperación (día de nómina)'
    )
    
    # Quién aprobó/rechazó
    approved_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='approved_advances',
        verbose_name='Aprobado por'
    )
    
    # Comprobante de desembolso
    disbursement_reference = models.CharField(
        max_length=100,
        blank=True,
        verbose_name='Referencia de desembolso'
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'Adelanto'
        verbose_name_plural = 'Adelantos'
        ordering = ['-request_date']
    
    def __str__(self):
        return f"Adelanto #{self.id} - {self.employee.user.get_full_name()} - ${self.amount}"
    
    def save(self, *args, **kwargs):
        # Calcular comisión automáticamente
        if not self.fee and self.company:
            percentage = self.company.advance_fee_percentage / 100
            self.fee = self.amount * percentage
        
        # Calcular total
        if not self.total_amount:
            self.total_amount = self.amount + self.fee
        
        super().save(*args, **kwargs)
    
    @property
    def is_pending(self):
        return self.status == 'pending'
    
    @property
    def is_approved(self):
        return self.status == 'approved'
    
    @property
    def is_disbursed(self):
        return self.status == 'disbursed'


class AdvanceHistory(models.Model):
    """Historial de cambios en adelantos"""
    
    advance = models.ForeignKey(
        Advance,
        on_delete=models.CASCADE,
        related_name='history',
        verbose_name='Adelanto'
    )
    status_from = models.CharField(
        max_length=20,
        blank=True,
        verbose_name='Estado anterior'
    )
    status_to = models.CharField(
        max_length=20,
        verbose_name='Estado nuevo'
    )
    changed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        verbose_name='Cambiado por'
    )
    notes = models.TextField(
        blank=True,
        verbose_name='Notas'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'Historial de Adelanto'
        verbose_name_plural = 'Historial de Adelantos'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Historial #{self.id} - Adelanto #{self.advance.id}"
