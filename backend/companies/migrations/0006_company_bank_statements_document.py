from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('companies', '0005_employer_required_documents'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='company',
            name='bank_statement_month_1',
        ),
        migrations.RemoveField(
            model_name='company',
            name='bank_statement_month_2',
        ),
        migrations.RemoveField(
            model_name='company',
            name='bank_statement_month_3',
        ),
        migrations.AddField(
            model_name='company',
            name='bank_statements_document',
            field=models.FileField(blank=True, help_text='Extracto bancario reciente en PDF, PNG o JPEG', null=True, upload_to='employer_documents/bank_statements/', verbose_name='Extractos bancarios de los ultimos 3 meses'),
        ),
    ]
