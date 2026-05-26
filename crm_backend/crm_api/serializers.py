from rest_framework import serializers
from .models import Client
from .models import Product



class ClientSerializer(serializers.ModelSerializer):
    class Meta:
        model = Client
        fields = '__all__'

from .models import Order, OrderLine

class OrderLineSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderLine
        fields = ['id', 'product_name', 'quantity', 'price']


class OrderSerializer(serializers.ModelSerializer):
    lines = OrderLineSerializer(many=True)

    class Meta:
        model = Order
        fields = '__all__'

    def create(self, validated_data):
        lines_data = validated_data.pop('lines')
        order = Order.objects.create(**validated_data)

        for line in lines_data:
            OrderLine.objects.create(order=order, **line)

        return order
    
from .models import Invoice

class InvoiceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Invoice
        fields = '__all__'

from rest_framework import serializers
from .models import Visit

class VisitSerializer(serializers.ModelSerializer):
    class Meta:
        model = Visit
        fields = '__all__'
        

from .models import Product

class ProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = '__all__'