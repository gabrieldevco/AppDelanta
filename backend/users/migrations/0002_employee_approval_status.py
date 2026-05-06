from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='employeeprofile',
            name='approval_status',
            field=models.CharField(choices=[('pending', 'Pendiente'), ('approved', 'Aprobado'), ('rejected', 'Rechazado')], default='pending', max_length=20, verbose_name='Estado de aprobacion'),
        ),
        migrations.AddField(
            model_name='employeeprofile',
            name='approved_at',
            field=models.DateTimeField(blank=True, null=True, verbose_name='Fecha de aprobacion'),
        ),
    ]
