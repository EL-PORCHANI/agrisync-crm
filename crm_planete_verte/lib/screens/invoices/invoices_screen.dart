import 'package:flutter/material.dart';
import '../../models/invoice.dart';
import '../../services/database_service.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  List<Invoice> invoices = [];
  bool showUnpaidOnly = false;

  @override
  void initState() {
    super.initState();
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    await DatabaseService.instance.refreshInvoiceStatuses();

    final data = showUnpaidOnly
        ? await DatabaseService.instance.getUnpaidInvoices()
        : await DatabaseService.instance.getInvoices();

    setState(() {
      invoices = data;
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'late':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Future<void> markAsPaid(int invoiceId) async {
    await DatabaseService.instance.updateInvoiceStatus(invoiceId, 'paid', 0);
    await loadInvoices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        actions: [
          Row(
            children: [
              const Text('Unpaid only'),
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
        ],
      ),
      body: invoices.isEmpty
          ? const Center(child: Text('No invoices found'))
          : ListView.builder(
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final invoice = invoices[index];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoice #${invoice.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Text(
                        'Amount due: ${invoice.amountDue.toStringAsFixed(2)} TND',
                      ),
                      Text(
                        'Due date: ${invoice.dueDate.split('T').first}',
                      ),
                      Text(
                        'Delay days: ${invoice.delayDays}',
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            invoice.status,
                            style: TextStyle(
                              color: getStatusColor(invoice.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          if (invoice.status != 'paid')
                            ElevatedButton(
                              onPressed: () => markAsPaid(invoice.id!),
                              child: const Text('Mark paid'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                );
              },
            ),
    );
  }
} 