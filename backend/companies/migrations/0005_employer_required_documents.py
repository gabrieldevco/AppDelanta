from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('companies', '0004_platform_settings_fee_ranges_windows'),
    ]

    operations = [
        migrations.AddField(
            model_name='company',
            name='rut_document',
            field=models.FileField(blank=True, help_text='Documento RUT en PDF, PNG o JPEG', null=True, upload_to='employer_documents/rut/', verbose_name='RUT'),
        ),
        migrations.AddField(
            model_name='company',
            name='legal_representative_id_document',
            field=models.FileField(blank=True, help_text='Copia de cedula del representante legal en PDF, PNG o JPEG', null=True, upload_to='employer_documents/legal_representative_id/', verbose_name='Copia de cedula del representante legal'),
        ),
        migrations.AddField(
            model_name='company',
            name='bank_statement_month_1',
            field=models.FileField(blank=True, help_text='Extracto bancario reciente en PDF, PNG o JPEG', null=True, upload_to='employer_documents/bank_statements/', verbose_name='Extracto bancario mes 1'),
        ),
        migrations.AddField(
            model_name='company',
            name='bank_statement_month_2',
            field=models.FileField(blank=True, help_text='Extracto bancario reciente en PDF, PNG o JPEG', null=True, upload_to='employer_documents/bank_statements/', verbose_name='Extracto bancario mes 2'),
        ),
        migrations.AddField(
            model_name='company',
            name='bank_statement_month_3',
            field=models.FileField(blank=True, help_text='Extracto bancario reciente en PDF, PNG o JPEG', null=True, upload_to='employer_documents/bank_statements/', verbose_name='Extracto bancario mes 3'),
        ),
        migrations.AlterField(
            model_name='company',
            name='chamber_of_commerce_document',
            field=models.FileField(blank=True, help_text='Documento PDF de cámara de comercio', null=True, upload_to='employer_documents/chamber_of_commerce/', verbose_name='Cámara de Comercio (PDF)'),
        ),
    ]
