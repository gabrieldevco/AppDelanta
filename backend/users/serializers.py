from rest_framework import serializers
from .models import User, EmployeeProfile, AdminProfile


class UserSerializer(serializers.ModelSerializer):
    """Serializer para usuario básico"""
    role_display = serializers.CharField(source='get_role_display', read_only=True)
    
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 
                  'role', 'role_display', 'phone', 'document_number', 
                  'is_active', 'created_at']
        read_only_fields = ['id', 'created_at']


class UserRegistrationSerializer(serializers.ModelSerializer):
    """Serializer para registro de usuarios"""
    password = serializers.CharField(write_only=True, min_length=8)
    password_confirm = serializers.CharField(write_only=True)
    
    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'password_confirm', 
                  'first_name', 'last_name', 'role', 'phone', 'document_number']
    
    def validate(self, data):
        if data['password'] != data['password_confirm']:
            raise serializers.ValidationError("Las contraseñas no coinciden")
        return data
    
    def create(self, validated_data):
        validated_data.pop('password_confirm')
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password'],
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', ''),
            role=validated_data.get('role', 'employee'),
            phone=validated_data.get('phone', ''),
            document_number=validated_data.get('document_number', '')
        )
        return user


class EmployeeProfileSerializer(serializers.ModelSerializer):
    """Serializer para perfil de empleado"""
    user = UserSerializer(read_only=True)
    company_name = serializers.CharField(source='company.name', read_only=True)
    
    class Meta:
        model = EmployeeProfile
        fields = ['id', 'user', 'company', 'company_name', 'salary',
                  'available_advance_limit', 'hire_date', 'bank_account', 'bank_name']


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
        
        try:
            user = User.objects.get(email=data['email'])
        except User.DoesNotExist:
            raise serializers.ValidationError("Credenciales inválidas")
        
        user = authenticate(username=user.username, password=data['password'])
        if not user:
            raise serializers.ValidationError("Credenciales inválidas")
        
        if not user.is_active:
            raise serializers.ValidationError("Usuario inactivo")
        
        data['user'] = user
        return data
