from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('companies', '0006_company_bank_statements_document'),
        ('users', '0002_employee_approval_status'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='EmployeeContract',
            fields=[
                (
                    'id',
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name='ID',
                    ),
                ),
                ('title', models.CharField(default='Contrato Appdelanta', max_length=180)),
                (
                    'contract_file',
                    models.FileField(
                        upload_to='employee_contracts/originals/',
                        verbose_name='Contrato',
                    ),
                ),
                (
                    'status',
                    models.CharField(
                        choices=[
                            ('pending', 'Pendiente de firma'),
                            ('signed', 'Firmado'),
                        ],
                        default='pending',
                        max_length=20,
                        verbose_name='Estado',
                    ),
                ),
                (
                    'signature_image',
                    models.FileField(
                        blank=True,
                        null=True,
                        upload_to='employee_contracts/signatures/',
                        verbose_name='Firma',
                    ),
                ),
                ('signed_at', models.DateTimeField(blank=True, null=True)),
                ('signer_ip', models.GenericIPAddressField(blank=True, null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                (
                    'company',
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name='employee_contracts',
                        to='companies.company',
                        verbose_name='Empresa',
                    ),
                ),
                (
                    'employee',
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name='contracts',
                        to='users.employeeprofile',
                        verbose_name='Empleado',
                    ),
                ),
                (
                    'uploaded_by',
                    models.ForeignKey(
                        blank=True,
                        null=True,
                        on_delete=django.db.models.deletion.SET_NULL,
                        related_name='uploaded_employee_contracts',
                        to=settings.AUTH_USER_MODEL,
                        verbose_name='Subido por',
                    ),
                ),
            ],
            options={
                'verbose_name': 'Contrato de empleado',
                'verbose_name_plural': 'Contratos de empleados',
                'ordering': ['-created_at'],
            },
        ),
    ]
