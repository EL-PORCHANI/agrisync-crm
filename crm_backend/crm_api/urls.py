from django.urls import path
from rest_framework.routers import DefaultRouter
from .views import (
    ClientViewSet,
    OrderViewSet,
    InvoiceViewSet,
    VisitViewSet,
    ProductViewSet,
    login_view,
)

router = DefaultRouter()
router.register(r'clients', ClientViewSet, basename='client')
router.register(r'orders', OrderViewSet, basename='order')
router.register(r'invoices', InvoiceViewSet, basename='invoice')
router.register(r'visits', VisitViewSet, basename='visit')
router.register(r'products', ProductViewSet, basename='product')

urlpatterns = [
    path('login/', login_view, name='login'),
]

urlpatterns += router.urls