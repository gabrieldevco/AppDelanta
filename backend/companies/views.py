from rest_framework import viewsets, status
from rest_framework.decorators import api_view, permission_classes, action
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework.exceptions import PermissionDenied
from django.core.mail import send_mail
from django.db import transaction
from django.utils import timezone
from decimal import Decimal

from .models import Company, CompanySettings
from .serializers import CompanySerializer, CompanyListSerializer, CompanySettingsSerializer
from users.models import User, EmployeeProfile
from users.serializers import EmployeeProfileSerializer


class CompanyViewSet(viewsets.ModelViewSet):
    """API endpoint para empresas"""
    queryset = Company.objects.all()
    serializer_class = CompanySerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        if user.is_admin:
            return Company.objects.all()
        elif user.is_employer:
            return Company.objects.filter(admin=user)
        return Company.objects.filter(employees__user=user)
    
    def get_serializer_class(self):
        if self.action == 'list':
            return CompanyListSerializer
        return CompanySerializer
    
    def perform_create(self, serializer):
        # Solo admins y empleadores pueden crear empresas
        if not (self.request.user.is_admin or self.request.user.is_employer):
            raise PermissionDenied("No tienes permiso para crear empresas")
        serializer.save()

    @action(detail=True, methods=['post'])
    def employees(self, request, pk=None):
        """Crear un empleado desde el modulo del empleador."""
        company = self.get_object()
        user = request.user
        if not (user.is_admin or (user.is_employer and company.admin == user)):
            return Response({'error': 'Sin permisos'}, status=status.HTTP_403_FORBIDDEN)

        required_fields = ['email', 'password', 'first_name', 'salary']
        missing = [field for field in required_fields if not request.data.get(field)]
        if missing:
            return Response(
                {'error': f'Campos requeridos: {", ".join(missing)}'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        email = request.data.get('email', '').strip().lower()
        username = request.data.get('username') or email.split('@')[0]
        username = username.strip().lower()
        if User.objects.filter(email=email).exists():
            return Response(
                {'email': 'Ya existe un usuario con este correo'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        base_username = username
        suffix = 1
        while User.objects.filter(username=username).exists():
            username = f'{base_username}.{company.id}.{suffix}'
            suffix += 1

        try:
            salary = Decimal(str(request.data.get('salary')))
        except Exception:
            return Response(
                {'salary': 'El salario no es valido'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        password = request.data.get('password')
        hire_date = request.data.get('hire_date') or None
        if isinstance(hire_date, str) and 'T' in hire_date:
            hire_date = hire_date.split('T', 1)[0]
        with transaction.atomic():
            employee_user = User.objects.create_user(
                username=username,
                email=email,
                password=password,
                first_name=request.data.get('first_name', '').strip(),
                last_name=request.data.get('last_name', '').strip(),
                role='employee',
                phone=request.data.get('phone', '') or '',
                document_number=request.data.get('document_number', '') or '',
            )
            profile = EmployeeProfile.objects.create(
                user=employee_user,
                company=company,
                salary=salary,
                available_advance_limit=salary * Decimal('0.5'),
                hire_date=hire_date,
                approval_status='approved',
                approved_at=timezone.now(),
            )

        send_mail(
            subject='Credenciales de acceso a AppDelanta',
            message=(
                f'Hola {employee_user.get_full_name()},\n\n'
                f'{company.name} creo tu usuario en AppDelanta.\n'
                f'Correo: {employee_user.email}\n'
                f'Contrasena temporal: {password}\n\n'
                'Ingresa a la app y cambia tu contrasena desde tu perfil.'
            ),
            from_email=None,
            recipient_list=[employee_user.email],
            fail_silently=True,
        )

        serializer = EmployeeProfileSerializer(profile, context={'request': request})
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=['patch'])
    def verify(self, request, pk=None):
        """Verificar o remover verificación de una empresa."""
        if not request.user.is_admin:
            return Response({'error': 'No autorizado'}, status=status.HTTP_403_FORBIDDEN)

        company = self.get_object()
        company.is_verified = request.data.get('is_verified', True)
        company.save(update_fields=['is_verified', 'updated_at'])
        serializer = self.get_serializer(company)
        return Response(serializer.data)


class CompanySettingsViewSet(viewsets.ModelViewSet):
    """API endpoint para configuración de empresas"""
    queryset = CompanySettings.objects.all()
    serializer_class = CompanySettingsSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        if user.is_admin:
            return CompanySettings.objects.all()
        elif user.is_employer:
            return CompanySettings.objects.filter(company__admin=user)
        return CompanySettings.objects.none()


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def company_stats(request, pk):
    """Obtener estadísticas de una empresa"""
    try:
        company = Company.objects.get(pk=pk)
    except Company.DoesNotExist:
        return Response({'error': 'Empresa no encontrada'}, status=status.HTTP_404_NOT_FOUND)
    
    # Verificar permisos
    user = request.user
    if not (user.is_admin or user.is_employer and company.admin == user):
        return Response({'error': 'Sin permisos'}, status=status.HTTP_403_FORBIDDEN)
    
    return Response({
        'total_disbursed': str(company.total_disbursed),
        'total_recovered': str(company.total_recovered),
        'employee_count': company.employee_count,
        'pending_advances': company.advances.filter(status='pending').count(),
        'approved_advances': company.advances.filter(status='approved').count(),
        'disbursed_advances': company.advances.filter(status='disbursed').count(),
    })


@api_view(['GET'])
@permission_classes([AllowAny])
def available_companies(request):
    """Listar empresas disponibles para registro de empleados"""
    companies = Company.objects.filter(is_active=True).values('id', 'name', 'legal_name')
    return Response(list(companies))


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def my_company(request):
    """Obtener la empresa del usuario empleador actual"""
    user = request.user
    if not user.is_employer:
        return Response({'error': 'Solo disponible para empleadores'}, 
                       status=status.HTTP_403_FORBIDDEN)
    
    try:
        company = Company.objects.get(admin=user)
        serializer = CompanySerializer(company)
        return Response(serializer.data)
    except Company.DoesNotExist:
        return Response({'error': 'No tienes una empresa registrada'}, 
                       status=status.HTTP_404_NOT_FOUND)
