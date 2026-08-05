import 'package:flutter/material.dart';
import '../../models/client.dart';
import '../../models/order.dart';
import '../../models/order_line.dart';
import '../../models/product.dart';
import '../../services/database_service.dart';
import '../../models/invoice.dart';

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  List<Client> clients = [];
  List<Product> products = [];

  Client? selectedClient;
  Map<int, int> quantities = {};
  final Map<int, TextEditingController> quantityControllers = {};

  double total = 0;

  @override
  void dispose() {
    for (final controller in quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
  

  @override
  void initState() {
    super.initState();
    loadData();
  }

  TextEditingController getQuantityController(int productId) {
  if (!quantityControllers.containsKey(productId)) {
    quantityControllers[productId] = TextEditingController(
      text: (quantities[productId] ?? 0).toString(),
    );
  }
  return quantityControllers[productId]!;
}

  Future<void> loadData() async {
    final db = DatabaseService.instance;

    final loadedClients = await db.getClients();
    final loadedProducts = await db.getProducts();

    setState(() {
      clients = loadedClients;
      products = loadedProducts;
    });
  }

  void calculateTotal() {
    double sum = 0;

    for (final product in products) {
      final qty = quantities[product.id] ?? 0;
      sum += qty * product.currentPrice;
    }

    setState(() {
      total = sum;
    });
  }

  Future<void> saveOrder() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (selectedClient == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please select a client')),
      );
      return;
    }

    final selectedItems = quantities.entries.where((e) => e.value > 0).toList();

    if (selectedItems.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Select at least one product')),
      );
      return;
    }

    for (final entry in selectedItems) {
      final productId = entry.key;
      final qty = entry.value;

      final isAvailable = await DatabaseService.instance
          .isStockAvailable(productId, 1, qty);

      if (!isAvailable) {
        final product = products.firstWhere((p) => p.id == productId);

        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Not enough stock for ${product.name}',
            ),
          ),
        );

        return;
      }
    }

    try {
      final now = DateTime.now();

      final order = Order(
        orderDate: now.toIso8601String(),
        status: 'draft',
        totalAmount: total,
        isValidated: 0,
        clientId: selectedClient!.id!,
        userId: 1,
        updatedAt: now.toIso8601String(),
      );

      final orderLines = <OrderLine>[];
      for (final entry in selectedItems) {
        final productId = entry.key;
        final qty = entry.value;

        final product = products.firstWhere((p) => p.id == productId);

        orderLines.add(
          OrderLine(
            quantity: qty,
            unitPrice: product.currentPrice,
            orderId: 0,
            productId: productId,
          ),
        );
      }

      final invoice = Invoice(
        amountDue: total,
        dueDate: now.add(const Duration(days: 3)).toIso8601String(),
        status: 'up_to_date',
        delayDays: 0,
        clientId: selectedClient!.id!,
        orderId: 0,
        updatedAt: now.toIso8601String(),
      );

      await DatabaseService.instance.insertOrderWithLinesAndInvoice(
        order: order,
        lines: orderLines,
        invoice: invoice,
      );

      if (!mounted) return;
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to save order: $e')),
      );
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Order'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<Client>(
              initialValue: selectedClient,
              decoration: const InputDecoration(
                labelText: 'Client',
                border: OutlineInputBorder(),
              ),
              items: clients.map((client) {
                return DropdownMenuItem<Client>(
                  value: client,
                  child: Text(client.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedClient = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: products.isEmpty
                  ? const Center(child: Text('No products found'))
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final qty = quantities[product.id] ?? 0;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${product.currentPrice.toStringAsFixed(2)} TND',
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        if (qty > 0) {
                                          final newQty = qty - 1;

                                          setState(() {
                                            if (newQty == 0) {
                                              quantities.remove(product.id);
                                            } else {
                                              quantities[product.id!] = newQty;
                                            }

                                            getQuantityController(product.id!).text = newQty.toString();
                                          });

                                          calculateTotal();
                                        }
                                      },
                                      icon: const Icon(Icons.remove_circle_outline),
                                    ),

                                    SizedBox(
                                      width: 50,
                                      child: TextFormField(
                                        controller: getQuantityController(product.id!),
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                                        ),
                                        onChanged: (value) {
                                          final newQty = int.tryParse(value) ?? 0;

                                          setState(() {
                                            if (newQty <= 0) {
                                              quantities.remove(product.id);
                                            } else {
                                              quantities[product.id!] = newQty;
                                            }
                                          });

                                          calculateTotal();
                                        },
                                      ),
                                    ),

                                    IconButton(
                                      onPressed: () {
                                        final newQty = qty + 1;

                                        setState(() {
                                          quantities[product.id!] = newQty;
                                          getQuantityController(product.id!).text = newQty.toString();
                                        });

                                        calculateTotal();
                                      },
                                      icon: const Icon(Icons.add_circle_outline),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              'Total: ${total.toStringAsFixed(2)} TND',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveOrder,
                child: const Text('Save Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
