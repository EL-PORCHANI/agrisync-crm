import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../models/stock.dart';
import '../../services/database_service.dart';

class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key});

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  List<Stock> stocks = [];
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final db = DatabaseService.instance;

    final loadedStocks = await db.getStockByZone(1);
    final loadedProducts = await db.getProducts();

    setState(() {
      stocks = loadedStocks;
      products = loadedProducts;
    });
  }

  String getProductName(int productId) {
    final product = products.firstWhere(
      (p) => p.id == productId,
      orElse: () => Product(
        id: 0,
        name: 'Unknown',
        currentPrice: 0,
      ),
    );

    return product.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock'),
      ),
      body: stocks.isEmpty
          ? const Center(child: Text('No stock found'))
          : ListView.builder(
              itemCount: stocks.length,
              itemBuilder: (context, index) {
                final stock = stocks[index];

                final isLowStock = stock.availableQuantity <= stock.alertThreshold;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(getProductName(stock.productId)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Available: ${stock.availableQuantity}'),
                        Text('Alert threshold: ${stock.alertThreshold}'),
                        if (isLowStock)
                          const Text(
                            'Low stock alert',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    trailing: Icon(
                      isLowStock ? Icons.warning_amber_rounded : Icons.check_circle,
                      color: isLowStock ? Colors.red : Colors.green,
                    ),
                  ),
                );
              },
            ),
    );
  }
}