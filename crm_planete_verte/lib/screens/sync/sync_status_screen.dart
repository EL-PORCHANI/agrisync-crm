import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../sync/sync_engine.dart';

class SyncStatusScreen extends StatefulWidget {
  const SyncStatusScreen({super.key});

  @override
  State<SyncStatusScreen> createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends State<SyncStatusScreen> {
  final db = DatabaseService.instance;
  final syncEngine = SyncEngine();

  int unsyncedClients = 0;
  int unsyncedOrders = 0;
  int unsyncedInvoices = 0;
  int unsyncedVisits = 0;
  int unsyncedStocks = 0;
  bool isSyncing = false;

  @override
  void initState() {
    super.initState();
    loadCounts();
  }

  Future<void> loadCounts() async {
    final clients = await db.countUnsyncedClients();
    final orders = await db.countUnsyncedOrders();
    final invoices = await db.countUnsyncedInvoices();
    final visits = await db.countUnsyncedVisits();
    final stocks = await db.countUnsyncedStocks();

    setState(() {
      unsyncedClients = clients;
      unsyncedOrders = orders;
      unsyncedInvoices = invoices;
      unsyncedVisits = visits;
      unsyncedStocks = stocks;
    });
  }


  Future<void> runSync() async {
    if (isSyncing) return;

    setState(() {
      isSyncing = true;
    });

    try {
      await syncEngine.syncAll();
      await loadCounts();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync completed')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSyncing = false;
        });
      }
    }
  }

  Widget buildCountCard(String title, int count) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(title),
        trailing: CircleAvatar(
          child: Text(count.toString()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPending = unsyncedClients +
        unsyncedOrders +
        unsyncedInvoices +
        unsyncedVisits +
        unsyncedStocks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Status'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            'Total pending sync: $totalPending',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          buildCountCard('Clients', unsyncedClients),
          buildCountCard('Orders', unsyncedOrders),
          buildCountCard('Invoices', unsyncedInvoices),
          buildCountCard('Visits', unsyncedVisits),
          buildCountCard('Stocks', unsyncedStocks),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: isSyncing ? null : runSync,
            icon: isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            label: Text(isSyncing ? 'Syncing...' : 'Run Sync'),
          ),
        ],
      ),
    );
  }
}