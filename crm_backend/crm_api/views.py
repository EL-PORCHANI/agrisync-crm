from rest_framework import viewsets
from .models import Client, Order, Invoice
from .serializers import ClientSerializer, OrderSerializer, InvoiceSerializer

class ClientViewSet(viewsets.ModelViewSet):
    serializer_class = ClientSerializer

    def get_queryset(self):
        queryset = Client.objects.all().order_by('-updated_at')
        phone = self.request.query_params.get('phone')

        if phone:
            queryset = queryset.filter(phone=phone)

        return queryset
    
from .models import Order
from .serializers import OrderSerializer

class OrderViewSet(viewsets.ModelViewSet):
    queryset = Order.objects.all().order_by('-created_at')
    serializer_class = OrderSerializer

from .models import Invoice
from .serializers import InvoiceSerializer

class InvoiceViewSet(viewsets.ModelViewSet):
    queryset = Invoice.objects.all().order_by('-updated_at')
    serializer_class = InvoiceSerializer

from rest_framework import viewsets
from .models import Visit
from .serializers import VisitSerializer

class VisitViewSet(viewsets.ModelViewSet):
    queryset = Visit.objects.all()
    serializer_class = VisitSerializer  

from .models import Product
from .serializers import ProductSerializer

class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.all().order_by('-updated_at')
    serializer_class = ProductSerializer


from django.contrib.auth import authenticate
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

@api_view(['POST'])
def login_view(request):
    username = request.data.get('username')
    password = request.data.get('password')

    user = authenticate(username=username, password=password)

    if user is not None:
        role = 'admin' if user.is_staff else 'commercial'

        return Response({
            'success': True,
            'user_id': user.id,
            'username': user.username,
            'role': role,
        })

    return Response(
        {'success': False, 'message': 'Invalid credentials'},
        status=status.HTTP_401_UNAUTHORIZED
    )