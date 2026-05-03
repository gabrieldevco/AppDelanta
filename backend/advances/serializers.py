from rest_framework import serializers
from .models import Advance, AdvanceHistory


class AdvanceHistorySerializer(serializers.ModelSerializer):
    changed_by_name = serializers.CharField(source='changed_by.get_full_name', read_only=True)

    class Meta:
        model = AdvanceHistory
        fields = [
            'id', 'status_from', 'status_to', 'changed_by', 'changed_by_name',
            'notes', 'created_at'
        ]


class AdvanceSerializer(serializers.ModelSerializer):
    employee_name = serializers.CharField(source='employee.user.get_full_name', read_only=True)
    employee_email = serializers.EmailField(source='employee.user.email', read_only=True)
    employee_phone = serializers.CharField(source='employee.user.phone', read_only=True)
    employee_document = serializers.CharField(source='employee.user.document_number', read_only=True)
    employee_bank_name = serializers.CharField(source='employee.bank_name', read_only=True)
    employee_bank_account = serializers.CharField(source='employee.bank_account', read_only=True)
    company_name = serializers.CharField(source='company.name', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    approved_by_name = serializers.CharField(source='approved_by.get_full_name', read_only=True)
    history = AdvanceHistorySerializer(many=True, read_only=True)

    class Meta:
        model = Advance
        fields = [
            'id', 'employee', 'employee_name', 'company', 'company_name',
            'employee_email', 'employee_phone', 'employee_document',
            'employee_bank_name', 'employee_bank_account',
            'amount', 'fee', 'total_amount', 'loan_days', 'status', 'status_display',
            'reason', 'request_date', 'approved_at', 'disbursed_at',
            'recovery_date', 'approved_by', 'approved_by_name',
            'disbursement_reference', 'created_at', 'updated_at', 'history'
        ]
        read_only_fields = ['id', 'request_date', 'total_amount', 'created_at', 'updated_at']

    def validate_amount(self, value):
        if value <= 0:
            raise serializers.ValidationError("El monto debe ser mayor a 0")
        return value


class AdvanceCreateSerializer(serializers.ModelSerializer):
    days = serializers.IntegerField(required=False, min_value=1, write_only=True)

    class Meta:
        model = Advance
        fields = ['amount', 'reason', 'days']

    def validate_amount(self, value):
        employee = self.context['request'].user.employee_profile
        company = employee.company

        if not company:
            raise serializers.ValidationError("No estas asociado a ninguna empresa")

        from companies.models import FeeRange

        FeeRange.ensure_defaults()
        min_amount = FeeRange.objects.order_by('min_amount').first().min_amount
        max_amount = FeeRange.objects.order_by('-max_amount').first().max_amount

        if value < min_amount:
            raise serializers.ValidationError(f"El monto minimo es ${min_amount}")

        if value > max_amount:
            raise serializers.ValidationError(f"El monto maximo es ${max_amount}")

        if value > employee.available_advance_limit:
            raise serializers.ValidationError(
                f"Excedes tu limite disponible de ${employee.available_advance_limit}"
            )

        return value

    def validate_days(self, value):
        from companies.models import PlatformSettings

        settings = PlatformSettings.get_solo()
        if value < settings.min_days or value > settings.max_days:
            raise serializers.ValidationError(
                f"El plazo debe estar entre {settings.min_days} y {settings.max_days} dias"
            )
        return value

    def create(self, validated_data):
        days = validated_data.pop('days', 30)
        return Advance.objects.create(loan_days=days, **validated_data)


class AdvanceStatusUpdateSerializer(serializers.ModelSerializer):
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
    employee_name = serializers.CharField(source='employee.user.get_full_name', read_only=True)
    employee_email = serializers.EmailField(source='employee.user.email', read_only=True)
    employee_phone = serializers.CharField(source='employee.user.phone', read_only=True)
    employee_document = serializers.CharField(source='employee.user.document_number', read_only=True)
    employee_bank_name = serializers.CharField(source='employee.bank_name', read_only=True)
    employee_bank_account = serializers.CharField(source='employee.bank_account', read_only=True)
    company_name = serializers.CharField(source='company.name', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)

    class Meta:
        model = Advance
        fields = [
            'id', 'employee', 'employee_name', 'company', 'company_name',
            'employee_email', 'employee_phone', 'employee_document',
            'employee_bank_name', 'employee_bank_account',
            'amount', 'fee', 'total_amount', 'loan_days',
            'status', 'status_display', 'reason', 'request_date',
            'approved_at', 'disbursed_at', 'recovery_date',
            'disbursement_reference', 'created_at', 'updated_at'
        ]
