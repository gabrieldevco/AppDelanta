from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'advances', views.AdvanceViewSet)

urlpatterns = [
    path('advances-stats/', views.advance_stats, name='advance-stats'),
    path('advances/calculate/', views.calculate_advance, name='calculate-advance'),
    path('advances/pending/', views.pending_advances, name='pending-advances'),
    path('advances/<int:pk>/approve/', views.approve_advance, name='approve-advance'),
    path('advances/<int:pk>/reject/', views.reject_advance, name='reject-advance'),
    path('advances/<int:pk>/disburse/', views.disburse_advance, name='disburse-advance'),
    path('advances/<int:pk>/undisburse/', views.undisburse_advance, name='undisburse-advance'),
    path('advances/<int:pk>/recover/', views.recover_advance, name='recover-advance'),
    path('advances/<int:pk>/unrecover/', views.unrecover_advance, name='unrecover-advance'),
    path('', include(router.urls)),
]
