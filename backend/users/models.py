from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    """Usuario base del sistema con roles"""
    
    ROLE_CHOICES = [
        ('employee', 'Empleado'),
        ('employer', 'Empleador'),
        ('admin', 'Administrador'),
    ]
    
    role = models.CharField(
        max_length=20,
        choices=ROLE_CHOICES,
        default='employee',
        verbose_name='Rol'
    )
    email = models.EmailField(unique=True)
    phone = models.CharField(max_length=20, blank=True, verbose_name='Teléfono')
    document_number = models.CharField(
        max_length=50, 
        blank=True, 
        verbose_name='Número de documento'
    )
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'Usuario'
        verbose_name_plural = 'Usuarios'
    
    def __str__(self):
        return f"{self.get_full_name()} ({self.get_role_display()})"
    
    @property
    def is_employee(self):
        return self.role == 'employee'
    
    @property
    def is_employer(self):
        return self.role == 'employer'
    
    @property
    def is_admin(self):
        return self.role == 'admin'


class EmployeeProfile(models.Model):
    """Perfil de empleado"""
    
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='employee_profile',
        verbose_name='Usuario'
    )
    company = models.ForeignKey(
        'companies.Company',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='employees',
        verbose_name='Empresa'
    )
    salary = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=0,
        verbose_name='Salario'
    )
    available_advance_limit = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=0,
        verbose_name='Límite disponible de adelanto'
    )
    hire_date = models.DateField(
        null=True,
        blank=True,
        verbose_name='Fecha de contratación'
    )
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
    
    class Meta:
        verbose_name = 'Perfil de Empleado'
        verbose_name_plural = 'Perfiles de Empleados'
    
    def __str__(self):
        return f"Empleado: {self.user.get_full_name()}"


class AdminProfile(models.Model):
    """Perfil de administrador"""
    
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='admin_profile',
        verbose_name='Usuario'
    )
    is_super_admin = models.BooleanField(
        default=False,
        verbose_name='¿Es super admin?'
    )
    permissions = models.JSONField(
        default=dict,
        blank=True,
        verbose_name='Permisos'
    )
    
    class Meta:
        verbose_name = 'Perfil de Administrador'
        verbose_name_plural = 'Perfiles de Administradores'
    
    def __str__(self):
        return f"Admin: {self.user.get_full_name()}"
