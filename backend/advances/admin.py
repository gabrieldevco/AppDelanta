from django.contrib import admin
from .models import Advance, AdvanceHistory


@admin.register(Advance)
class AdvanceAdmin(admin.ModelAdmin):
    list_display = ['id', 'employee', 'company', 'amount', 'fee', 'status', 'request_date', 'approved_by']
    list_filter = ['status', 'request_date', 'disbursed_at']
    search_fields = [
        'employee__user__first_name',
        'employee__user__last_name',
        'employee__user__email',
        'company__name'
    ]
    autocomplete_fields = ['employee', 'company', 'approved_by']
    date_hierarchy = 'request_date'
    
    fieldsets = (
        ('Información del solicitante', {
            'fields': ('employee', 'company')
        }),
        ('Montos', {
            'fields': ('amount', 'fee', 'total_amount')
        }),
        ('Estado y fechas', {
            'fields': ('status', 'request_date', 'approved_at', 'disbursed_at', 'recovery_date')
        }),
        ('Aprobación', {
            'fields': ('approved_by', 'disbursement_reference')
        }),
        ('Motivo', {
            'fields': ('reason',)
        }),
    )
    
    readonly_fields = ['request_date', 'total_amount']


@admin.register(AdvanceHistory)
class AdvanceHistoryAdmin(admin.ModelAdmin):
    list_display = ['advance', 'status_from', 'status_to', 'changed_by', 'created_at']
    list_filter = ['created_at']
    search_fields = ['advance__id']
    autocomplete_fields = ['advance', 'changed_by']
    readonly_fields = ['created_at']
