import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/database_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final data = await DatabaseService.instance.getProducts();
    setState(() {
      products = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: products.isEmpty
          ? const Center(child: Text('No products found'))
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return ListTile(
                  title: Text(product.name),
                  subtitle: Text(
                    '${product.category ?? 'No category'} - ${product.currentPrice.toStringAsFixed(2)} TND',
                  ),
                );
              },
            ),
    );
  }
}