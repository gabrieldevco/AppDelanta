from rest_framework import serializers
from .models import Advance, AdvanceHistory


class AdvanceHistorySerializer(serializers.ModelSerializer):
    """Serializer para historial de adelantos"""
    changed_by_name = serializers.CharField(source='changed_by.get_full_name', read_only=True)
    
    class Meta:
        model = AdvanceHistory
        fields = ['id', 'status_from', 'status_to', 'changed_by', 'changed_by_name', 
                  'notes', 'created_at']


class AdvanceSerializer(serializers.ModelSerializer):
    """Serializer para adelantos"""
    employee_name = serializers.CharField(source='employee.user.get_full_name', read_only=True)
    company_name = serializers.CharField(source='company.name', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    approved_by_name = serializers.CharField(source='approved_by.get_full_name', read_only=True)
    history = AdvanceHistorySerializer(many=True, read_only=True)
    
    class Meta:
        model = Advance
        fields = ['id', 'employee', 'employee_name', 'company', 'company_name',
                  'amount', 'fee', 'total_amount', 'status', 'status_display',
                  'reason', 'request_date', 'approved_at', 'disbursed_at', 
                  'recovery_date', 'approved_by', 'approved_by_name',
                  'disbursement_reference', 'created_at', 'updated_at', 'history']
        read_only_fields = ['id', 'request_date', 'total_amount', 'created_at', 'updated_at']
    
    def validate_amount(self, value):
        """Validar monto del adelanto"""
        if value <= 0:
            raise serializers.ValidationError("El monto debe ser mayor a 0")
        return value


class AdvanceCreateSerializer(serializers.ModelSerializer):
    """Serializer para crear solicitud de adelanto"""
    
    class Meta:
        model = Advance
        fields = ['amount', 'reason']
    
    def validate_amount(self, value):
        employee = self.context['request'].user.employee_profile
        company = employee.company
        
        if not company:
            raise serializers.ValidationError("No estás asociado a ninguna empresa")
        
        # Verificar mínimo y máximo
        if value < company.settings.min_advance_amount:
            raise serializers.ValidationError(
                f"El monto mínimo es ${company.settings.min_advance_amount}"
            )
        
        if value > company.settings.max_advance_amount:
            raise serializers.ValidationError(
                f"El monto máximo es ${company.settings.max_advance_amount}"
            )
        
        # Verificar límite disponible
        if value > employee.available_advance_limit:
            raise serializers.ValidationError(
                f"Excedes tu límite disponible de ${employee.available_advance_limit}"
            )
        
        return value


class AdvanceStatusUpdateSerializer(serializers.ModelSerializer):
    """Serializer para actualizar estado de adelanto"""
    notes = serializers.CharField(required=False, allow_blank=True)
    
    class Meta:
        model = Advance
        fields = ['status', 'notes']
    
    def validate_status(self, value):
        valid_transitions = {
            'pending': ['approved', 'rejected'],
            'approved': ['disbursed', 'cancelled'],
            'disbursed': ['recovered'],
        }
        
        current_status = self.instance.status if self.instance else None
        
        if current_status and value not in valid_transitions.get(current_status, []):
            raise serializers.ValidationError(
                f"No se puede cambiar de '{current_status}' a '{value}'"
            )
        
        return value


class AdvanceListSerializer(serializers.ModelSerializer):
    """Serializer simplificado para lista de adelantos"""
    employee_name = serializers.CharField(source='employee.user.get_full_name', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    
    class Meta:
        model = Advance
        fields = ['id', 'employee_name', 'amount', 'total_amount', 'status', 
                  'status_display', 'request_date']
