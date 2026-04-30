from django.db import models
from django.contrib.auth.models import User


class Client(models.Model):
    name = models.CharField(max_length=150)
    phone = models.CharField(max_length=20, unique=True)
    address = models.TextField()
    gps_location = models.CharField(max_length=255, blank=True, null=True)
    latitude = models.FloatField(blank=True, null=True)
    longitude = models.FloatField(blank=True, null=True)
    pricing_category = models.CharField(max_length=50, blank=True, null=True)
    zone_id = models.IntegerField()
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name
    
class Order(models.Model):
    client = models.ForeignKey(Client, on_delete=models.CASCADE, related_name='orders')
    total_amount = models.FloatField()
    status = models.CharField(max_length=50, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Order {self.id} - {self.client.name}"


class OrderLine(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='lines')
    product_name = models.CharField(max_length=150)
    quantity = models.IntegerField()
    price = models.FloatField()

    def __str__(self):
        return f"{self.product_name} x{self.quantity}"
    
class Invoice(models.Model):
    amount_due = models.FloatField()
    due_date = models.DateField()
    status = models.CharField(max_length=50, default='up_to_date')
    delay_days = models.IntegerField(default=0)

    client = models.ForeignKey(Client, on_delete=models.CASCADE)
    order = models.ForeignKey(Order, on_delete=models.CASCADE)

    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Invoice {self.id} - {self.amount_due}"
    
class Visit(models.Model):
    visit_date = models.DateField()
    visit_time = models.TimeField()
    gps_location = models.CharField(max_length=255)
    latitude = models.FloatField()
    longitude = models.FloatField()
    validation_status = models.CharField(max_length=50)

    client = models.ForeignKey('Client', on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.CASCADE)

    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Visit {self.id}"