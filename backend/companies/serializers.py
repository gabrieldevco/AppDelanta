from rest_framework import serializers
from .models import Company, CompanySettings


class CompanySettingsSerializer(serializers.ModelSerializer):
    """Serializer para configuración de empresa"""
    
    class Meta:
        model = CompanySettings
        fields = '__all__'


class CompanySerializer(serializers.ModelSerializer):
    """Serializer para empresa"""
    admin_name = serializers.CharField(source='admin.get_full_name', read_only=True)
    settings = CompanySettingsSerializer(read_only=True)
    employee_count = serializers.IntegerField(read_only=True)
    
    class Meta:
        model = Company
        fields = ['id', 'name', 'legal_name', 'tax_id', 'address', 'phone', 'email',
                  'admin', 'admin_name', 'max_advance_percentage', 'advance_fee_percentage',
                  'is_active', 'is_verified', 'created_at', 'settings', 'employee_count']
        read_only_fields = ['id', 'created_at', 'is_verified']


class CompanyListSerializer(serializers.ModelSerializer):
    """Serializer simplificado para lista de empresas"""
    
    class Meta:
        model = Company
        fields = ['id', 'name', 'tax_id', 'is_active', 'is_verified', 'employee_count']
