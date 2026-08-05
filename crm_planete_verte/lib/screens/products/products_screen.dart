import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_list_tile_card.dart';
import '../../widgets/app_screen_scaffold.dart';

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
    return AppScreenScaffold(
      title: 'Products',
      subtitle:
          'Consult product catalog, prices, categories and stock indicators.',
      icon: Icons.inventory_2_outlined,
      child: products.isEmpty
          ? const AppEmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No products found',
              message:
                  'The local catalog will appear here after loading products.',
            )
          : ListView.separated(
              padding: AppSpacing.screenPadding,
              itemCount: products.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final product = products[index];

                return AppMotion.fadeSlide(
                  delay: index * 20,
                  child: AppListTileCard(
                    title: product.name,
                    subtitle:
                        '${product.category ?? 'No category'} | ${product.currentPrice.toStringAsFixed(2)} TND | Stock: ${product.stockQuantity}',
                    icon: Icons.eco_outlined,
                    accentColor: AppColors.olive,
                  ),
                );
              },
            ),
    );
  }
}
