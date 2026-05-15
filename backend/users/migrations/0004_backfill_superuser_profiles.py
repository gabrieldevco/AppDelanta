from django.db import migrations


def create_missing_superuser_profiles(apps, schema_editor):
    User = apps.get_model('users', 'User')
    SuperUserProfile = apps.get_model('users', 'SuperUserProfile')

    for user in User.objects.filter(is_superuser=True):
        if user.role != 'admin':
            user.role = 'admin'
            user.save(update_fields=['role'])
        SuperUserProfile.objects.get_or_create(user=user)


class Migration(migrations.Migration):
    dependencies = [
        ('users', '0003_superuserprofile'),
    ]

    operations = [
        migrations.RunPython(
            create_missing_superuser_profiles,
            migrations.RunPython.noop,
        ),
    ]
