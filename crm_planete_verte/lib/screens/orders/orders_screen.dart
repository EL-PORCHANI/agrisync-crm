import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/database_service.dart';
import 'add_order_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> orders = [];

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
  final data = await DatabaseService.instance.getOrders();
  setState(() {
    orders = data;
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: orders.isEmpty
          ? const Center(child: Text('No orders yet'))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];

                return ListTile(
                  title: Text('Order #${order.id}'),
                  subtitle: Text(
                    'Total: ${order.totalAmount.toStringAsFixed(2)} TND',
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddOrderScreen(),
            ),
          );

          if (result == true) {
            await loadOrders();
          }
        },
        child: const Icon(Icons.add),
      ),  
       
    );
  }

  
}