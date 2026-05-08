from rest_framework import serializers
from .models import User, EmployeeProfile, AdminProfile


class UserSerializer(serializers.ModelSerializer):
    """Serializer para usuario basico"""
    role_display = serializers.CharField(source='get_role_display', read_only=True)

    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'first_name', 'last_name',
            'role', 'role_display', 'phone', 'document_number',
            'is_active', 'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class UserRegistrationSerializer(serializers.ModelSerializer):
    """Serializer para registro de usuarios"""
    password = serializers.CharField(write_only=True, min_length=6)
    password_confirm = serializers.CharField(write_only=True)
    salary = serializers.DecimalField(max_digits=12, decimal_places=2, required=False, allow_null=True)
    business_name = serializers.CharField(required=False, allow_blank=True)
    company_name = serializers.CharField(required=False, allow_blank=True)
    bank_account = serializers.CharField(required=False, allow_blank=True)
    bank_name = serializers.CharField(required=False, allow_blank=True)
    company_id = serializers.IntegerField(required=False, allow_null=True)
    rut_document = serializers.FileField(required=False, allow_null=True, write_only=True)
    chamber_of_commerce_document = serializers.FileField(required=False, allow_null=True, write_only=True)
    legal_representative_id_document = serializers.FileField(required=False, allow_null=True, write_only=True)
    bank_statements_document = serializers.FileField(required=False, allow_null=True, write_only=True)

    allowed_document_extensions = {'.pdf', '.png', '.jpg', '.jpeg'}
    employer_document_fields = [
        'rut_document',
        'chamber_of_commerce_document',
        'legal_representative_id_document',
        'bank_statements_document',
    ]

    class Meta:
        model = User
        fields = [
            'username', 'email', 'password', 'password_confirm',
            'first_name', 'last_name', 'role', 'phone', 'document_number',
            'salary', 'business_name', 'company_name', 'bank_account',
            'bank_name', 'company_id', 'rut_document',
            'chamber_of_commerce_document',
            'legal_representative_id_document', 'bank_statements_document',
        ]

    def _validate_document_file(self, field_name, value):
        if not value:
            return
        import os

        extension = os.path.splitext(value.name)[1].lower()
        if extension not in self.allowed_document_extensions:
            raise serializers.ValidationError({
                field_name: 'El archivo debe ser PDF, PNG, JPG o JPEG'
            })

    def validate(self, data):
        if data.get('email'):
            data['email'] = data['email'].strip().lower()
        if data.get('username'):
            data['username'] = data['username'].strip().lower()

        if data['password'] != data['password_confirm']:
            raise serializers.ValidationError({'password': 'Las contrasenas no coinciden'})

        role = data.get('role', 'employer')

        if role == 'admin':
            raise serializers.ValidationError({
                'role': 'El registro publico no permite crear administradores'
            })

        if role == 'employee':
            raise serializers.ValidationError({
                'role': 'Los empleados deben ser registrados por su empleador'
            })

        elif role == 'employer':
            if not data.get('business_name'):
                raise serializers.ValidationError({'business_name': 'La razon social es requerida para empleadores'})
            if not data.get('company_name'):
                raise serializers.ValidationError({'company_name': 'El nombre de la empresa es requerido para empleadores'})
            for field_name in self.employer_document_fields:
                if not data.get(field_name):
                    raise serializers.ValidationError({
                        field_name: 'Este documento es requerido para empleadores'
                    })
                self._validate_document_file(field_name, data[field_name])

        return data

    def create(self, validated_data):
        salary = validated_data.pop('salary', None)
        business_name = validated_data.pop('business_name', '')
        company_name = validated_data.pop('company_name', '')
        bank_account = validated_data.pop('bank_account', '')
        bank_name = validated_data.pop('bank_name', '')
        company_id = validated_data.pop('company_id', None)
        employer_documents = {
            field: validated_data.pop(field, None)
            for field in self.employer_document_fields
        }

        validated_data.pop('password_confirm')

        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password'],
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', ''),
            role=validated_data.get('role', 'employer'),
            phone=validated_data.get('phone', ''),
            document_number=validated_data.get('document_number', ''),
        )

        if user.role == 'employee':
            self._create_employee_profile(user, salary, bank_account, bank_name, company_id)
        elif user.role == 'employer':
            self._create_employer_company(user, business_name, company_name, employer_documents)
        elif user.role == 'admin':
            self._create_admin_profile(user)

        return user

    def _create_employee_profile(self, user, salary, bank_account='', bank_name='', company_id=None):
        """Crear perfil de empleado pendiente de aprobacion por empleador."""
        from decimal import Decimal
        from companies.models import Company

        salary_decimal = Decimal(str(salary)) if salary else Decimal('0')
        advance_limit = salary_decimal * Decimal('0.5')

        company = None
        if company_id:
            try:
                company = Company.objects.get(id=company_id, is_active=True)
            except Company.DoesNotExist:
                pass

        profile = EmployeeProfile.objects.create(
            user=user,
            salary=salary_decimal,
            available_advance_limit=advance_limit,
            bank_account=bank_account or '',
            bank_name=bank_name or '',
            company=company,
            approval_status='pending',
        )
        if company:
            self._notify_employer_about_employee(user, company, profile)
        self._notify_admins_about_employee(user, company, profile)

    def _notify_employer_about_employee(self, user, company, profile):
        from notifications.models import Notification

        Notification.objects.create(
            user=company.admin,
            type='warning',
            title='Empleado pendiente de aprobacion',
            message=(
                f'{user.get_full_name()} se registro como empleado de '
                f'{company.name}. Salario: ${profile.salary}. '
                'Aprueba o deniega su vinculacion.'
            ),
            link=f'/employee-approvals/{profile.id}',
        )

    def _notify_admins_about_employee(self, user, company, profile):
        """Notificar a todos los admins sobre nuevo empleado registrado"""
        from notifications.models import Notification
        from .models import User

        admins = User.objects.filter(role='admin', is_active=True)
        for admin in admins:
            Notification.objects.create(
                user=admin,
                type='info',
                title='Nuevo empleado registrado',
                message=(
                    f'{user.get_full_name()} se registro como empleado de '
                    f'{company.name if company else "una empresa"}. '
                    f'Empresa: {company.name if company else "N/A"}.'
                ),
                link=f'/admin/users',
            )

    def _create_employer_company(self, user, business_name, company_name, employer_documents):
        """Crear empresa para empleador"""
        from companies.models import Company, CompanySettings

        company = Company.objects.create(
            name=company_name or business_name,
            legal_name=business_name,
            admin=user,
            phone=user.phone or '',
            email=user.email,
            **{key: value for key, value in employer_documents.items() if value},
        )
        CompanySettings.objects.create(company=company)
        self._notify_admins_about_employer(user, company)

    def _notify_admins_about_employer(self, user, company):
        """Notificar a todos los admins sobre nuevo empleador registrado"""
        from notifications.models import Notification
        from .models import User

        admins = User.objects.filter(role='admin', is_active=True)
        for admin in admins:
            Notification.objects.create(
                user=admin,
                type='info',
                title='Nuevo empleador registrado',
                message=(
                    f'{user.get_full_name()} se registro como empleador. '
                    f'Empresa: {company.name}.'
                ),
                link=f'/admin/users',
            )

    def _create_admin_profile(self, user):
        """Crear perfil de administrador"""
        AdminProfile.objects.create(user=user)


class EmployeeProfileSerializer(serializers.ModelSerializer):
    """Serializer para perfil de empleado"""
    user = UserSerializer(read_only=True)
    company_name = serializers.CharField(source='company.name', read_only=True)
    approval_status_display = serializers.CharField(source='get_approval_status_display', read_only=True)

    class Meta:
        model = EmployeeProfile
        fields = [
            'id', 'user', 'company', 'company_name', 'salary',
            'available_advance_limit', 'hire_date', 'bank_account',
            'bank_name', 'approval_status', 'approval_status_display',
            'approved_at',
        ]


class AdminProfileSerializer(serializers.ModelSerializer):
    """Serializer para perfil de administrador"""
    user = UserSerializer(read_only=True)

    class Meta:
        model = AdminProfile
        fields = ['id', 'user', 'is_super_admin', 'permissions']


class LoginSerializer(serializers.Serializer):
    """Serializer para login"""
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        from django.contrib.auth import authenticate
        
        data['email'] = data['email'].strip().lower()

        try:
            user = User.objects.get(email__iexact=data['email'])
        except User.DoesNotExist:
            raise serializers.ValidationError({'email': 'Credenciales invalidas'})

        user = authenticate(username=user.username, password=data['password'])
        if not user:
            raise serializers.ValidationError({'password': 'Credenciales invalidas'})

        if not user.is_active:
            raise serializers.ValidationError({'email': 'Usuario inactivo'})

        data['user'] = user
        return data


class UserWithProfileSerializer(serializers.ModelSerializer):
    """Serializer para usuario con su perfil/empresa completo"""
    role_display = serializers.CharField(source='get_role_display', read_only=True)
    employee_profile = EmployeeProfileSerializer(read_only=True)
    admin_profile = AdminProfileSerializer(read_only=True)
    company = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'first_name', 'last_name',
            'role', 'role_display', 'phone', 'document_number',
            'is_active', 'created_at', 'employee_profile',
            'admin_profile', 'company',
        ]
        read_only_fields = ['id', 'created_at']

    def get_company(self, obj):
        if obj.role == 'employer' and hasattr(obj, 'company'):
            from companies.serializers import CompanySerializer
            return CompanySerializer(obj.company, context=self.context).data
        return None
