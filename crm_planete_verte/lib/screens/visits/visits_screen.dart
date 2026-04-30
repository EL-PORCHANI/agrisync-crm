import 'package:flutter/material.dart';
import '../../models/visit.dart';
import '../../services/database_service.dart';
import 'add_visit_screen.dart';

class VisitsScreen extends StatefulWidget {
  const VisitsScreen({super.key});

  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen> {
  List<Visit> visits = [];

  @override
  void initState() {
    super.initState();
    loadVisits();
  }

  Future<void> loadVisits() async {
    final data = await DatabaseService.instance.getVisits();
    setState(() {
      visits = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visits'),
      ),
      body: visits.isEmpty
          ? const Center(child: Text('No visits found'))
          : ListView.builder(
              itemCount: visits.length,
              itemBuilder: (context, index) {
                final visit = visits[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Visit #${visit.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('Date: ${visit.visitDate.split('T').first}'),
                        Text('Time: ${visit.visitTime}'),
                        Text(
                          'Status: ${visit.validationStatus}',
                          style: TextStyle(
                            color: getStatusColor(visit.validationStatus),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddVisitScreen(),
                  ),
                );

                if (result == true) {
                  await loadVisits();
                }
              },
              child: const Icon(Icons.add),
            ),
    );
  }
  Color getStatusColor(String status) {
    switch (status) {
      case 'valid':
        return Colors.green;
      case 'invalid':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}