from django.db import migrations, models


def seed_platform_settings(apps, schema_editor):
    PlatformSettings = apps.get_model('companies', 'PlatformSettings')
    FeeRange = apps.get_model('companies', 'FeeRange')
    DisbursementWindow = apps.get_model('companies', 'DisbursementWindow')

    PlatformSettings.objects.get_or_create(
        pk=1,
        defaults={
            'interest_rate_monthly': 2.50,
            'max_salary_percentage': 50.00,
            'min_days': 1,
            'max_days': 30,
        },
    )

    if not FeeRange.objects.exists():
        FeeRange.objects.bulk_create([
            FeeRange(min_amount=50000, max_amount=150000, fee=5000, order=1),
            FeeRange(min_amount=150001, max_amount=400000, fee=10000, order=2),
            FeeRange(min_amount=400001, max_amount=1000000, fee=15000, order=3),
        ])

    if not DisbursementWindow.objects.exists():
        DisbursementWindow.objects.bulk_create([
            DisbursementWindow(name='Franja 1', start_time='06:00', end_time='12:00', processing_time='13:00', order=1),
            DisbursementWindow(name='Franja 2', start_time='12:01', end_time='17:00', processing_time='18:00', order=2),
        ])


class Migration(migrations.Migration):

    dependencies = [
        ('companies', '0003_company_bank_account_company_bank_name_and_more'),
    ]

    operations = [
        migrations.CreateModel(
            name='PlatformSettings',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('interest_rate_monthly', models.DecimalField(decimal_places=2, default=2.5, max_digits=5)),
                ('max_salary_percentage', models.DecimalField(decimal_places=2, default=50.0, max_digits=5)),
                ('min_days', models.PositiveSmallIntegerField(default=1)),
                ('max_days', models.PositiveSmallIntegerField(default=30)),
                ('updated_at', models.DateTimeField(auto_now=True)),
            ],
            options={
                'verbose_name': 'ConfiguraciÃ³n Global',
                'verbose_name_plural': 'ConfiguraciÃ³n Global',
            },
        ),
        migrations.CreateModel(
            name='FeeRange',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('min_amount', models.DecimalField(decimal_places=2, max_digits=12)),
                ('max_amount', models.DecimalField(decimal_places=2, max_digits=12)),
                ('fee', models.DecimalField(decimal_places=2, max_digits=12)),
                ('order', models.PositiveSmallIntegerField(default=1)),
            ],
            options={
                'ordering': ['order', 'min_amount'],
            },
        ),
        migrations.CreateModel(
            name='DisbursementWindow',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=50)),
                ('start_time', models.TimeField()),
                ('end_time', models.TimeField()),
                ('processing_time', models.TimeField()),
                ('order', models.PositiveSmallIntegerField(default=1)),
            ],
            options={
                'ordering': ['order', 'start_time'],
            },
        ),
        migrations.RunPython(seed_platform_settings, migrations.RunPython.noop),
    ]
