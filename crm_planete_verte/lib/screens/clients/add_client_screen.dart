import 'package:flutter/material.dart';
import '../../models/client.dart';
import '../../services/database_service.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  Future<void> saveClient() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = phoneController.text.trim();

    try {
      final phoneExists = await DatabaseService.instance.clientPhoneExists(phone);

      if (phoneExists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This phone number already exists'),
          ),
        );
        return;
      }

      final client = Client(
        name: nameController.text.trim(),
        phone: phone,
        address: addressController.text.trim(),
        gpsLocation: '',
        latitude: 0,
        longitude: 0,
        pricingCategory: 'A',
        zoneId: 1,
        updatedAt: DateTime.now().toIso8601String(),
      );

      await DatabaseService.instance.insertClient(client);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save client: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Client')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Name is too short';
                  }
                  return null;
                },
              ),
             TextFormField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
              validator: (value) {
                final phone = value?.trim() ?? '';

                if (phone.isEmpty) {
                  return 'Phone is required';
                }
                if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
                  return 'Phone must contain digits only';
                }
                if (phone.length != 8) {
                  return 'Phone must be exactly 8 digits';
                }
                return null;
              },
            ),
            TextFormField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Address is required';
                }
                if (value.trim().length < 4) {
                  return 'Address is too short';
                }
                return null;
              },
            ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveClient,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}