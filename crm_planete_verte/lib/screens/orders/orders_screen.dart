import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_list_tile_card.dart';
import '../../widgets/app_screen_scaffold.dart';
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
    return AppScreenScaffold(
      title: 'Orders',
      subtitle: 'Track local customer orders created during field activity.',
      icon: Icons.shopping_cart_outlined,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddOrderScreen()),
          );

          if (result == true) {
            await loadOrders();
          }
        },
        child: const Icon(Icons.add),
      ),
      child: orders.isEmpty
          ? const AppEmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'No orders yet',
              message:
                  'Create an order to generate invoice data and sales history.',
            )
          : ListView.separated(
              padding: AppSpacing.screenPadding,
              itemCount: orders.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final order = orders[index];

                return AppMotion.fadeSlide(
                  delay: index * 22,
                  child: AppListTileCard(
                    title: 'Order #${order.id}',
                    subtitle:
                        '${order.status} | ${order.totalAmount.toStringAsFixed(2)} TND',
                    icon: Icons.receipt_long_outlined,
                    accentColor: AppColors.amber,
                  ),
                );
              },
            ),
    );
  }
}
