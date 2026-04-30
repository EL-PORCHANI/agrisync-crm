import 'package:flutter/material.dart';
import 'clients/clients_screen.dart';
import 'products/products_screen.dart';
import 'orders/orders_screen.dart';
import 'stocks/stocks_screen.dart';
import 'invoices/invoices_screen.dart';
import 'visits/visits_screen.dart';
import '../sync/sync_engine.dart';
import 'sync/sync_status_screen.dart';
import 'dashboard/dashboard_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    DashboardScreen(),
    ClientsScreen(),
    ProductsScreen(),
    OrdersScreen(),
    StocksScreen(),
    InvoicesScreen(),
    VisitsScreen(),
    SyncStatusScreen(),
  ];
  final SyncEngine syncEngine = SyncEngine();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await syncEngine.syncAll();

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sync completed')),
          );
        },
        child: const Icon(Icons.sync),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Clients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warehouse),
            label: 'Stock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Invoices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Visits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sync),
            label: 'Sync',
          ),
        ],
      ),
    );
  }
}