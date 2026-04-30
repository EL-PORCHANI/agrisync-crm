from rest_framework.routers import DefaultRouter
from .views import ClientViewSet, OrderViewSet, InvoiceViewSet, VisitViewSet

router = DefaultRouter()
router.register(r'clients', ClientViewSet, basename='client')
router.register(r'orders', OrderViewSet, basename='order')
router.register(r'invoices', InvoiceViewSet, basename='invoice')
router.register(r'visits', VisitViewSet, basename='visit')

urlpatterns = router.urls