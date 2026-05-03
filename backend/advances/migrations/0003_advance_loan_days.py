from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('companies', '0004_platform_settings_fee_ranges_windows'),
        ('advances', '0002_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='advance',
            name='loan_days',
            field=models.PositiveSmallIntegerField(default=30, verbose_name='DÃ­as del adelanto'),
        ),
    ]
