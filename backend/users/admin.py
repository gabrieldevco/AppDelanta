from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, EmployeeProfile, AdminProfile


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ['username', 'email', 'first_name', 'last_name', 'role', 'is_active', 'created_at']
    list_filter = ['role', 'is_active', 'is_staff', 'created_at']
    search_fields = ['username', 'email', 'first_name', 'last_name', 'document_number']
    
    fieldsets = BaseUserAdmin.fieldsets + (
        ('Información adicional', {
            'fields': ('role', 'phone', 'document_number')
        }),
    )


@admin.register(EmployeeProfile)
class EmployeeProfileAdmin(admin.ModelAdmin):
    list_display = ['user', 'company', 'salary', 'available_advance_limit', 'hire_date']
    list_filter = ['company', 'hire_date']
    search_fields = ['user__first_name', 'user__last_name', 'user__email']
    autocomplete_fields = ['user', 'company']


@admin.register(AdminProfile)
class AdminProfileAdmin(admin.ModelAdmin):
    list_display = ['user', 'is_super_admin']
    list_filter = ['is_super_admin']
    search_fields = ['user__first_name', 'user__last_name', 'user__email']
    autocomplete_fields = ['user']
