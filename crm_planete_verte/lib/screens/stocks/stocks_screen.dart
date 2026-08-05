import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../models/stock.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_list_tile_card.dart';
import '../../widgets/app_screen_scaffold.dart';
import '../../widgets/app_status_badge.dart';

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
      orElse: () =>
          Product(id: 0, name: 'Unknown', currentPrice: 0, stockQuantity: 0),
    );

    return product.name;
  }

  @override
  Widget build(BuildContext context) {
    return AppScreenScaffold(
      title: 'Stock',
      subtitle: 'Follow zone stock availability and low-stock alerts.',
      icon: Icons.warehouse_outlined,
      child: stocks.isEmpty
          ? const AppEmptyState(
              icon: Icons.warehouse_outlined,
              title: 'No stock found',
              message:
                  'Stock quantities will appear after local seeding or sync.',
            )
          : ListView.separated(
              padding: AppSpacing.screenPadding,
              itemCount: stocks.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final stock = stocks[index];

                final isLowStock =
                    stock.availableQuantity <= stock.alertThreshold;

                return AppMotion.fadeSlide(
                  delay: index * 20,
                  child: AppListTileCard(
                    title: getProductName(stock.productId),
                    subtitle:
                        'Available: ${stock.availableQuantity} | Alert threshold: ${stock.alertThreshold}',
                    icon: isLowStock
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline,
                    accentColor: isLowStock ? AppColors.red : AppColors.olive,
                    trailing: AppStatusBadge(
                      label: isLowStock ? 'Low stock' : 'Available',
                      color: isLowStock ? AppColors.red : AppColors.olive,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
