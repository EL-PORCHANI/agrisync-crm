import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../sync/sync_engine.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_kpi_card.dart';
import '../../widgets/app_list_tile_card.dart';
import '../../widgets/app_screen_scaffold.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sync completed')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sync failed: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isSyncing = false;
        });
      }
    }
  }

  Widget buildCountCard(String title, int count) {
    return AppListTileCard(
      title: title,
      subtitle: count == 0
          ? 'No pending local records'
          : '$count local record(s) waiting for synchronization',
      icon: count == 0 ? Icons.check_circle_outline : Icons.sync_problem,
      accentColor: count == 0 ? AppColors.olive : AppColors.amber,
      trailing: CircleAvatar(
        backgroundColor: count == 0
            ? AppColors.olive.withValues(alpha: 0.14)
            : AppColors.amber,
        child: Text(
          count.toString(),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPending =
        unsyncedClients +
        unsyncedOrders +
        unsyncedInvoices +
        unsyncedVisits +
        unsyncedStocks;

    return AppScreenScaffold(
      title: 'Synchronization',
      subtitle: 'Control offline-to-online data synchronization status.',
      icon: Icons.sync_outlined,
      child: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          AppKpiCard(
            title: 'Total Pending Sync',
            value: totalPending.toString(),
            icon: totalPending == 0
                ? Icons.cloud_done_outlined
                : Icons.cloud_sync,
            color: totalPending == 0 ? AppColors.olive : AppColors.amber,
          ),
          const SizedBox(height: AppSpacing.lg),
          buildCountCard('Clients', unsyncedClients),
          const SizedBox(height: AppSpacing.md),
          buildCountCard('Orders', unsyncedOrders),
          const SizedBox(height: AppSpacing.md),
          buildCountCard('Invoices', unsyncedInvoices),
          const SizedBox(height: AppSpacing.md),
          buildCountCard('Visits', unsyncedVisits),
          const SizedBox(height: AppSpacing.md),
          buildCountCard('Stocks', unsyncedStocks),
          const SizedBox(height: AppSpacing.xl),
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
