import 'package:flutter/material.dart';
import '../../models/invoice.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_screen_scaffold.dart';
import '../../widgets/app_status_badge.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  List<Invoice> invoices = [];
  Map<int, String> clientNames = {};
  bool showUnpaidOnly = false;

  @override
  void initState() {
    super.initState();
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    await DatabaseService.instance.createMissingInvoicesForOrders();
    await DatabaseService.instance.refreshInvoiceStatuses();

    final data = showUnpaidOnly
        ? await DatabaseService.instance.getUnpaidInvoices()
        : await DatabaseService.instance.getInvoices();

    final names = <int, String>{};
    for (final invoice in data) {
      names[invoice.clientId] =
          await DatabaseService.instance.getClientName(invoice.clientId) ??
          'Client #${invoice.clientId}';
    }

    if (!mounted) return;
    setState(() {
      invoices = data;
      clientNames = names;
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return AppColors.olive;
      case 'late':
        return AppColors.amber;
      case 'critical':
        return AppColors.red;
      default:
        return AppColors.blue;
    }
  }

  Future<void> markAsPaid(int invoiceId) async {
    await DatabaseService.instance.updateInvoiceStatus(invoiceId, 'paid', 0);
    await loadInvoices();
  }

  @override
  Widget build(BuildContext context) {
    return AppScreenScaffold(
      title: 'Invoices',
      subtitle: 'Monitor payment status and generated customer invoices.',
      icon: Icons.receipt_long_outlined,
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              Text(
                'Unpaid only',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Switch(
                value: showUnpaidOnly,
                onChanged: (value) async {
                  setState(() {
                    showUnpaidOnly = value;
                  });
                  await loadInvoices();
                },
              ),
            ],
          ),
        ),
      ],
      child: invoices.isEmpty
          ? const AppEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No invoices found',
              message: 'Invoices appear after orders are created locally.',
            )
          : ListView.separated(
              padding: AppSpacing.screenPadding,
              itemCount: invoices.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final invoice = invoices[index];
                final clientName =
                    clientNames[invoice.clientId] ??
                    'Client #${invoice.clientId}';

                return AppMotion.fadeSlide(
                  delay: index * 20,
                  child: Card(
                    child: Padding(
                      padding: AppSpacing.cardPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Invoice #${invoice.id}',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              AppStatusBadge(
                                label: invoice.status,
                                color: getStatusColor(invoice.status),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            '${invoice.amountDue.toStringAsFixed(2)} TND',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Client: $clientName | Order #${invoice.orderId}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            'Due date: ${invoice.dueDate.split('T').first} | Delay days: ${invoice.delayDays}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (invoice.status != 'paid')
                                OutlinedButton.icon(
                                  onPressed: () => markAsPaid(invoice.id!),
                                  icon: const Icon(Icons.check_circle_outline),
                                  label: const Text('Mark paid'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
