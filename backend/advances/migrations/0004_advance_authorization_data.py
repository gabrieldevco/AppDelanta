from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('advances', '0003_advance_loan_days'),
    ]

    operations = [
        migrations.AddField(
            model_name='advance',
            name='authorization_data',
            field=models.JSONField(blank=True, default=dict, verbose_name='Autorizacion de descuento'),
        ),
    ]
