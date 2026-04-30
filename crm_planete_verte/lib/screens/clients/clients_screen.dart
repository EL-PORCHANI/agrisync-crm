import 'package:flutter/material.dart';
import '../../models/client.dart';
import '../../services/database_service.dart';
import 'add_client_screen.dart';
import 'edit_client_screen.dart';
import '../../services/api_service.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  List<Client> clients = [];

  @override
  void initState() {
    super.initState();
    loadClients();
  }

  Future<void> loadClients() async {
    final data = await DatabaseService.instance.getClients();
    setState(() {
      clients = data;
    });
  }

  Future<void> addTestClient() async {
    final newClient = Client(
      name: 'New Client',
      phone: '99999999',
      address: 'Tunis',
      gpsLocation: '36.8,10.1',
      latitude: 36.8,
      longitude: 10.1,
      pricingCategory: 'B',
      zoneId: 1,
      updatedAt: DateTime.now().toIso8601String(),
    );

    await DatabaseService.instance.insertClient(newClient);
    await loadClients();
  }

  Future<void> deleteClient(int id) async {
    await DatabaseService.instance.deleteClient(id);
    await loadClients();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddClientScreen(),
            ),
          );

          if (result == true) {
            await loadClients();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: clients.isEmpty
          ? const Center(child: Text('No clients yet'))
          : ListView.builder(
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                return ListTile(
                  title: Text(client.name),
                  subtitle: Text(client.phone ?? 'No phone'),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditClientScreen(client: client),
                      ),
                    );

                    if (result == true) {
                      await loadClients();
                    }
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await deleteClient(client.id!);
                    },
                  ),
                );
              },
            ),
            
    );
  }
  final apiService = ApiService();
  Future<void> testSendFirstClientToApi() async {
    if (clients.isEmpty) return;

    try {
      await apiService.sendClient(clients.first);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client sent to API successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('API error: $e')),
      );
    }
  }
}