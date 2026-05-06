from rest_framework import viewsets, status
from rest_framework.decorators import api_view, permission_classes, action
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from rest_framework.parsers import MultiPartParser, FormParser
from django.db import models
from django.utils import timezone

from .models import User, EmployeeProfile, AdminProfile
from .serializers import (
    UserSerializer, UserRegistrationSerializer, 
    EmployeeProfileSerializer, AdminProfileSerializer, LoginSerializer,
    UserWithProfileSerializer
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

    @action(detail=False, methods=['post'], url_path='join-company')
    def join_company(self, request):
        """Permitir que un empleado seleccione su empresa desde el perfil."""
        if not request.user.is_employee:
            return Response(
                {'error': 'Solo los empleados pueden seleccionar empresa'},
                status=status.HTTP_403_FORBIDDEN
            )

        company_id = request.data.get('company_id')
        if not company_id:
            return Response(
                {'company_id': 'Debes seleccionar una empresa'},
                status=status.HTTP_400_BAD_REQUEST
            )

        from companies.models import Company

        try:
            company = Company.objects.get(id=company_id, is_active=True)
        except Company.DoesNotExist:
            return Response(
                {'company_id': 'Empresa no encontrada'},
                status=status.HTTP_404_NOT_FOUND
            )

        profile = request.user.employee_profile
        profile.company = company
        profile.approval_status = 'pending'
        profile.approved_at = None

        bank_name = request.data.get('bank_name')
        bank_account = request.data.get('bank_account')
        if bank_name is not None:
            profile.bank_name = bank_name
        if bank_account is not None:
            profile.bank_account = bank_account

        profile.save(update_fields=['company', 'bank_name', 'bank_account', 'approval_status', 'approved_at'])
        from notifications.models import Notification
        Notification.objects.create(
            user=company.admin,
            type='warning',
            title='Empleado pendiente de aprobacion',
            message=(
                f"{request.user.get_full_name()} solicito vincularse a "
                f"{company.name}. Aprueba o deniega su solicitud."
            ),
            link='/employee-approvals'
        )
        return Response(self.get_serializer(profile).data)

    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        """Aprobar la vinculacion de un empleado a la empresa del empleador."""
        profile = self.get_object()
        user = request.user
        if not (user.is_admin or (user.is_employer and profile.company == user.company)):
            return Response({'error': 'No autorizado'}, status=status.HTTP_403_FORBIDDEN)

        profile.approval_status = 'approved'
        profile.approved_at = timezone.now()
        profile.save(update_fields=['approval_status', 'approved_at'])
        self._notify_employee(profile, 'Vinculacion aprobada', 'Tu empleador aprobo tu vinculacion.')
        return Response(self.get_serializer(profile).data)

    @action(detail=True, methods=['post'])
    def reject(self, request, pk=None):
        """Denegar la vinculacion de un empleado a la empresa del empleador."""
        profile = self.get_object()
        user = request.user
        if not (user.is_admin or (user.is_employer and profile.company == user.company)):
            return Response({'error': 'No autorizado'}, status=status.HTTP_403_FORBIDDEN)

        profile.approval_status = 'rejected'
        profile.approved_at = None
        profile.save(update_fields=['approval_status', 'approved_at'])
        self._notify_employee(profile, 'Vinculacion denegada', 'Tu empleador denego tu vinculacion.')
        return Response(self.get_serializer(profile).data)

    def _notify_employee(self, profile, title, message):
        from notifications.models import Notification
        Notification.objects.create(
            user=profile.user,
            type='info',
            title=title,
            message=message,
        )


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
    """Registrar nuevo usuario con soporte para archivos"""
    # Manejar datos multipart (con archivos) o JSON
    data = request.data
    
    serializer = UserRegistrationSerializer(data=data)
    if serializer.is_valid():
        user = serializer.save()
        token, _ = Token.objects.get_or_create(user=user)
        return Response({
            'user': UserWithProfileSerializer(user, context={'request': request}).data,
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
            'user': UserWithProfileSerializer(user, context={'request': request}).data,
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
    # Usar UserWithProfileSerializer para incluir perfil y empresa
    data = UserWithProfileSerializer(user, context={'request': request}).data
    return Response(data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def change_password(request):
    """Cambiar contraseña del usuario actual"""
    old_password = request.data.get('old_password')
    new_password = request.data.get('new_password')
    
    if not old_password or not new_password:
        return Response(
            {'error': 'Se requieren old_password y new_password'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    user = request.user
    
    # Verificar contraseña actual
    if not user.check_password(old_password):
        return Response(
            {'error': 'La contraseña actual es incorrecta'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Cambiar contraseña
    user.set_password(new_password)
    user.save()
    
    return Response({'message': 'Contraseña cambiada exitosamente'})


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_management(request):
    """Vista de gestión de usuarios para administradores"""
    if not request.user.is_admin:
        return Response({'error': 'No autorizado'}, status=status.HTTP_403_FORBIDDEN)
    
    # Obtener todos los usuarios con sus perfiles
    users = User.objects.all().select_related(
        'employee_profile', 'admin_profile', 'company'
    )
    
    role_filter = request.query_params.get('role', None)
    if role_filter:
        users = users.filter(role=role_filter)
    
    search = request.query_params.get('search', None)
    if search:
        users = users.filter(
            models.Q(username__icontains=search) |
            models.Q(email__icontains=search) |
            models.Q(first_name__icontains=search) |
            models.Q(last_name__icontains=search)
        )
    
    serializer = UserWithProfileSerializer(users, many=True, context={'request': request})
    return Response(serializer.data)


@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def verify_company(request, company_id):
    """Verificar empresa (cambiar is_verified a True)"""
    if not request.user.is_admin:
        return Response({'error': 'No autorizado'}, status=status.HTTP_403_FORBIDDEN)
    
    from companies.models import Company
    from companies.serializers import CompanyDetailAdminSerializer
    
    try:
        company = Company.objects.get(id=company_id)
        company.is_verified = True
        company.save()
        return Response(CompanyDetailAdminSerializer(company, context={'request': request}).data)
    except Company.DoesNotExist:
        return Response({'error': 'Empresa no encontrada'}, status=status.HTTP_404_NOT_FOUND)
