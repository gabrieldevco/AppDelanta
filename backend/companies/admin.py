from django.contrib import admin
from .models import Company, CompanySettings


@admin.register(Company)
class CompanyAdmin(admin.ModelAdmin):
    list_display = ['name', 'tax_id', 'admin', 'employee_count', 'is_active', 'is_verified', 'created_at']
    list_filter = ['is_active', 'is_verified', 'created_at']
    search_fields = ['name', 'legal_name', 'tax_id', 'email']
    autocomplete_fields = ['admin']
    
    fieldsets = (
        ('Información básica', {
            'fields': ('name', 'legal_name', 'tax_id')
        }),
        ('Contacto', {
            'fields': ('address', 'phone', 'email')
        }),
        ('Administración', {
            'fields': ('admin',)
        }),
        ('Configuración de adelantos', {
            'fields': ('max_advance_percentage', 'advance_fee_percentage')
        }),
        ('Estado', {
            'fields': ('is_active', 'is_verified')
        }),
    )


@admin.register(CompanySettings)
class CompanySettingsAdmin(admin.ModelAdmin):
    list_display = ['company', 'payment_day', 'min_advance_amount', 'max_advance_amount']
    search_fields = ['company__name']
    autocomplete_fields = ['company']
