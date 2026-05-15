from django.db.models.signals import post_save
from django.dispatch import receiver

from .models import SuperUserProfile, User


@receiver(post_save, sender=User)
def ensure_superuser_profile(sender, instance, **kwargs):
    if instance.is_superuser:
        SuperUserProfile.objects.get_or_create(user=instance)
