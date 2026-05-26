from django.contrib import admin
from .models import Client, Order, OrderLine, Invoice, Visit, Product

admin.site.register(Client)
admin.site.register(Order)
admin.site.register(OrderLine)
admin.site.register(Invoice)
admin.site.register(Visit)
admin.site.register(Product)