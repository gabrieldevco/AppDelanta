import os

from django.core.management.base import BaseCommand, CommandError

from users.models import AdminProfile, User


class Command(BaseCommand):
    help = 'Create or update the Ricardo Vanegas administrator account.'

    def add_arguments(self, parser):
        parser.add_argument(
            '--password',
            default=os.environ.get('RICARDO_ADMIN_PASSWORD'),
            help='Password for the admin user. Can also be set with RICARDO_ADMIN_PASSWORD.',
        )

    def handle(self, *args, **options):
        password = options['password']
        if not password:
            raise CommandError(
                'Provide --password or set RICARDO_ADMIN_PASSWORD before running this command.'
            )

        user, created = User.objects.update_or_create(
            email='rickyvanegas10@gmail.com',
            defaults={
                'username': 'rickyvanegas10',
                'first_name': 'Ricardo',
                'last_name': 'Vanegas',
                'role': 'admin',
                'is_active': True,
                'is_staff': True,
                'is_superuser': True,
            },
        )
        user.set_password(password)
        user.save(update_fields=['password'])

        AdminProfile.objects.get_or_create(
            user=user,
            defaults={'is_super_admin': True},
        )

        action = 'created' if created else 'updated'
        self.stdout.write(
            self.style.SUCCESS(
                f'Admin {action}: Ricardo Vanegas <rickyvanegas10@gmail.com>'
            )
        )
