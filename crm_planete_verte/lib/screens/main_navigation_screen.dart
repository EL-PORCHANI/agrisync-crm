import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../sync/sync_engine.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import 'clients/clients_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'invoices/invoices_screen.dart';
import 'login_screen.dart';
import 'orders/orders_screen.dart';
import 'products/products_screen.dart';
import 'stocks/stocks_screen.dart';
import 'sync/sync_status_screen.dart';
import 'visits/visits_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final SyncEngine syncEngine = SyncEngine();
  final ApiService apiService = ApiService();

  int currentIndex = 0;
  String connectedUsername = 'Commercial';
  bool isSyncing = false;

  late final List<_NavigationItem> navigationItems = const [
    _NavigationItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      page: DashboardScreen(),
    ),
    _NavigationItem(
      label: 'Clients',
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      page: ClientsScreen(),
    ),
    _NavigationItem(
      label: 'Products',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      page: ProductsScreen(),
    ),
    _NavigationItem(
      label: 'Orders',
      icon: Icons.shopping_cart_outlined,
      selectedIcon: Icons.shopping_cart,
      page: OrdersScreen(),
    ),
    _NavigationItem(
      label: 'Stock',
      icon: Icons.warehouse_outlined,
      selectedIcon: Icons.warehouse,
      page: StocksScreen(),
    ),
    _NavigationItem(
      label: 'Invoices',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      page: InvoicesScreen(),
    ),
    _NavigationItem(
      label: 'Visits',
      icon: Icons.location_on_outlined,
      selectedIcon: Icons.location_on,
      page: VisitsScreen(),
    ),
    _NavigationItem(
      label: 'Sync',
      icon: Icons.sync_outlined,
      selectedIcon: Icons.sync,
      page: SyncStatusScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    loadConnectedUser();
  }

  Future<void> loadConnectedUser() async {
    final username = await apiService.getStoredUsername();

    if (!mounted) return;

    setState(() {
      connectedUsername = username;
    });
  }

  Future<void> syncAll() async {
    setState(() {
      isSyncing = true;
    });

    try {
      await syncEngine.syncAll();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Synchronization completed')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSyncing = false;
        });
      }
    }
  }

  Future<void> logout() async {
    await apiService.logout();

    if (!mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = navigationItems[currentIndex];
    final isCompactWidth = MediaQuery.sizeOf(context).width < 560;

    return Scaffold(
      drawer: _buildNavigationDrawer(),
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo_agrisync.png',
              height: 34,
              width: 34,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            const Text('AgriSync AI'),
          ],
        ),
        actions: [
          IconButton(
            icon: isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            tooltip: 'Synchronize',
            onPressed: isSyncing ? null : syncAll,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: logout,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildConnectedUserRow(currentItem.label),
          Expanded(
            child: AnimatedSwitcher(
              duration: AppMotion.normal,
              switchInCurve: AppMotion.curve,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0.03, 0),
                  end: Offset.zero,
                ).animate(animation);

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(currentIndex),
                child: currentItem.page,
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isSyncing ? null : syncAll,
        icon: isSyncing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.sync),
        label: Text(isSyncing ? 'Syncing' : 'Sync'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: changePage,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: !isCompactWidth,
        showUnselectedLabels: !isCompactWidth,
        items: navigationItems.map((item) {
          final isSelected = navigationItems[currentIndex] == item;
          return BottomNavigationBarItem(
            icon: Icon(isSelected ? item.selectedIcon : item.icon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildConnectedUserRow(String sectionName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: const BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepGreen.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.forest,
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  connectedUsername,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  'Connected commercial workspace',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Chip(
            label: Text(sectionName),
            avatar: Icon(navigationItems[currentIndex].selectedIcon, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: AppColors.brandGradient,
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Image.asset(
                      'assets/images/logo_agrisync.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AgriSync AI',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          connectedUsername,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.sm),
                itemCount: navigationItems.length,
                itemBuilder: (context, index) {
                  final item = navigationItems[index];
                  final isSelected = index == currentIndex;

                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: AppColors.forest.withValues(alpha: 0.10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    leading: Icon(isSelected ? item.selectedIcon : item.icon),
                    title: Text(item.label),
                    onTap: () {
                      Navigator.of(context).pop();
                      changePage(index);
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: logout,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.page,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;
}
