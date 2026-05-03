from django.db import models


class Company(models.Model):
    """Empresa/Empleador"""
    
    name = models.CharField(
        max_length=255,
        verbose_name='Nombre de la empresa'
    )
    legal_name = models.CharField(
        max_length=255,
        blank=True,
        verbose_name='Razón social'
    )
    tax_id = models.CharField(
        max_length=50,
        blank=True,
        verbose_name='NIT/RUC'
    )
    address = models.TextField(
        blank=True,
        verbose_name='Dirección'
    )
    phone = models.CharField(
        max_length=20,
        blank=True,
        verbose_name='Teléfono'
    )
    email = models.EmailField(
        blank=True,
        verbose_name='Correo electrónico'
    )
    
    # Administrador de la empresa
    admin = models.OneToOneField(
        'users.User',
        on_delete=models.CASCADE,
        related_name='company',
        limit_choices_to={'role': 'employer'},
        verbose_name='Administrador'
    )
    
    # Cámara de comercio (PDF)
    chamber_of_commerce_document = models.FileField(
        upload_to='chamber_of_commerce/',
        blank=True,
        null=True,
        verbose_name='Cámara de Comercio (PDF)',
        help_text='Documento PDF de cámara de comercio'
    )
    
    # Datos bancarios del empleador
    bank_account = models.CharField(
        max_length=100,
        blank=True,
        verbose_name='Cuenta bancaria'
    )
    bank_name = models.CharField(
        max_length=100,
        blank=True,
        verbose_name='Banco'
    )
    
    # Configuración de adelantos
    max_advance_percentage = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        default=50.00,
        verbose_name='Porcentaje máximo de adelanto (%)'
    )
    advance_fee_percentage = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        default=2.00,
        verbose_name='Porcentaje de comisión (%)'
    )
    
    # Estado
    is_active = models.BooleanField(
        default=True,
        verbose_name='¿Activa?'
    )
    is_verified = models.BooleanField(
        default=False,
        verbose_name='¿Verificada?'
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'Empresa'
        verbose_name_plural = 'Empresas'
    
    def __str__(self):
        return self.name
    
    @property
    def employee_count(self):
        return self.employees.count()
    
    @property
    def total_disbursed(self):
        """Total desembolsado a empleados"""
        from advances.models import Advance
        return Advance.objects.filter(
            employee__company=self,
            status='disbursed'
        ).aggregate(
            total=models.Sum('amount')
        )['total'] or 0
    
    @property
    def total_recovered(self):
        """Total recuperado de empleados"""
        from advances.models import Advance
        return Advance.objects.filter(
            employee__company=self,
            status='recovered'
        ).aggregate(
            total=models.Sum('amount')
        )['total'] or 0


class CompanySettings(models.Model):
    """Configuración adicional de la empresa"""
    
    company = models.OneToOneField(
        Company,
        on_delete=models.CASCADE,
        related_name='settings',
        verbose_name='Empresa'
    )
    
    # Configuración de pagos
    payment_day = models.PositiveSmallIntegerField(
        default=15,
        verbose_name='Día de pago',
        help_text='Día del mes en que se realiza el pago de nómina'
    )
    
    # Configuración de notificaciones
    notify_on_advance_request = models.BooleanField(
        default=True,
        verbose_name='Notificar solicitudes de adelanto'
    )
    notify_on_advance_approved = models.BooleanField(
        default=True,
        verbose_name='Notificar aprobaciones'
    )
    
    # Límites
    min_advance_amount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=50000,
        verbose_name='Monto mínimo de adelanto'
    )
    max_advance_amount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=1000000,
        verbose_name='Monto máximo de adelanto'
    )
    
    class Meta:
        verbose_name = 'Configuración de Empresa'
        verbose_name_plural = 'Configuraciones de Empresas'
    
    def __str__(self):
        return f"Configuración: {self.company.name}"


class PlatformSettings(models.Model):
    interest_rate_monthly = models.DecimalField(max_digits=5, decimal_places=2, default=2.50)
    max_salary_percentage = models.DecimalField(max_digits=5, decimal_places=2, default=50.00)
    min_days = models.PositiveSmallIntegerField(default=1)
    max_days = models.PositiveSmallIntegerField(default=30)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'ConfiguraciÃ³n Global'
        verbose_name_plural = 'ConfiguraciÃ³n Global'

    @classmethod
    def get_solo(cls):
        settings, _ = cls.objects.get_or_create(pk=1)
        return settings

    def __str__(self):
        return 'ConfiguraciÃ³n global de plataforma'


class FeeRange(models.Model):
    min_amount = models.DecimalField(max_digits=12, decimal_places=2)
    max_amount = models.DecimalField(max_digits=12, decimal_places=2)
    fee = models.DecimalField(max_digits=12, decimal_places=2)
    order = models.PositiveSmallIntegerField(default=1)

    class Meta:
        ordering = ['order', 'min_amount']

    @classmethod
    def defaults(cls):
        return [
            {'min_amount': 50000, 'max_amount': 150000, 'fee': 5000, 'order': 1},
            {'min_amount': 150001, 'max_amount': 400000, 'fee': 10000, 'order': 2},
            {'min_amount': 400001, 'max_amount': 1000000, 'fee': 15000, 'order': 3},
        ]

    @classmethod
    def ensure_defaults(cls):
        if not cls.objects.exists():
            for item in cls.defaults():
                cls.objects.create(**item)

    @classmethod
    def fee_for_amount(cls, amount):
        cls.ensure_defaults()
        fee_range = cls.objects.filter(min_amount__lte=amount, max_amount__gte=amount).first()
        if fee_range:
            return fee_range.fee
        return cls.objects.order_by('-max_amount').first().fee

    def __str__(self):
        return f"${self.min_amount} - ${self.max_amount}: ${self.fee}"


class DisbursementWindow(models.Model):
    name = models.CharField(max_length=50)
    start_time = models.TimeField()
    end_time = models.TimeField()
    processing_time = models.TimeField()
    order = models.PositiveSmallIntegerField(default=1)

    class Meta:
        ordering = ['order', 'start_time']

    @classmethod
    def defaults(cls):
        return [
            {'name': 'Franja 1', 'start_time': '06:00', 'end_time': '12:00', 'processing_time': '13:00', 'order': 1},
            {'name': 'Franja 2', 'start_time': '12:01', 'end_time': '17:00', 'processing_time': '18:00', 'order': 2},
        ]

    @classmethod
    def ensure_defaults(cls):
        if not cls.objects.exists():
            for item in cls.defaults():
                cls.objects.create(**item)

    def __str__(self):
        return f"{self.name}: {self.start_time} - {self.end_time}"
