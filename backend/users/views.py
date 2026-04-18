from rest_framework import viewsets, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.authtoken.models import Token

from .models import User, EmployeeProfile, AdminProfile
from .serializers import (
    UserSerializer, UserRegistrationSerializer, 
    EmployeeProfileSerializer, AdminProfileSerializer, LoginSerializer
)


class UserViewSet(viewsets.ModelViewSet):
    """API endpoint para usuarios"""
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        if user.is_admin:
            return User.objects.all()
        elif user.is_employer:
            return User.objects.filter(employee_profile__company=user.company)
        return User.objects.filter(id=user.id)


class EmployeeProfileViewSet(viewsets.ModelViewSet):
    """API endpoint para perfiles de empleados"""
    queryset = EmployeeProfile.objects.all()
    serializer_class = EmployeeProfileSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        if user.is_admin:
            return EmployeeProfile.objects.all()
        elif user.is_employer:
            return EmployeeProfile.objects.filter(company=user.company)
        return EmployeeProfile.objects.filter(user=user)


class AdminProfileViewSet(viewsets.ModelViewSet):
    """API endpoint para perfiles de administradores"""
    queryset = AdminProfile.objects.all()
    serializer_class = AdminProfileSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        if self.request.user.is_admin:
            return AdminProfile.objects.all()
        return AdminProfile.objects.filter(user=self.request.user)


@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    """Registrar nuevo usuario"""
    serializer = UserRegistrationSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        token, _ = Token.objects.get_or_create(user=user)
        return Response({
            'user': UserSerializer(user).data,
            'token': token.key
        }, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    """Iniciar sesión"""
    serializer = LoginSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.validated_data['user']
        token, _ = Token.objects.get_or_create(user=user)
        return Response({
            'user': UserSerializer(user).data,
            'token': token.key
        })
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout(request):
    """Cerrar sesión"""
    request.user.auth_token.delete()
    return Response({'message': 'Sesión cerrada exitosamente'})


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def me(request):
    """Obtener información del usuario actual"""
    user = request.user
    data = UserSerializer(user).data
    
    # Agregar información adicional según el rol
    if user.is_employee and hasattr(user, 'employee_profile'):
        data['profile'] = EmployeeProfileSerializer(user.employee_profile).data
    elif user.is_admin and hasattr(user, 'admin_profile'):
        data['profile'] = AdminProfileSerializer(user.admin_profile).data
    
    return Response(data)
