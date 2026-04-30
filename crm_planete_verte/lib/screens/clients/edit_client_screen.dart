import 'package:flutter/material.dart';
import '../../models/client.dart';
import '../../services/database_service.dart';

class EditClientScreen extends StatefulWidget {
  final Client client;

  const EditClientScreen({
    super.key,
    required this.client,
  });

  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.client.name);
    phoneController = TextEditingController(text: widget.client.phone ?? '');
    addressController = TextEditingController(text: widget.client.address ?? '');
  }

  Future<void> updateClient() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = phoneController.text.trim();

    try {
      final phoneExists = await DatabaseService.instance
          .clientPhoneExistsForOtherClient(phone, widget.client.id!);

      if (phoneExists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This phone number already exists'),
          ),
        );
        return;
      }

      final updatedClient = Client(
        id: widget.client.id,
        name: nameController.text.trim(),
        phone: phone,
        address: addressController.text.trim(),
        gpsLocation: widget.client.gpsLocation,
        latitude: widget.client.latitude,
        longitude: widget.client.longitude,
        pricingCategory: widget.client.pricingCategory,
        zoneId: widget.client.zoneId,
        updatedAt: DateTime.now().toIso8601String(),
        isSynced: 0,
      );

      await DatabaseService.instance.updateClient(widget.client.id!, updatedClient);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update client: $e')),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Client'),
      ),
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
                onPressed: updateClient,
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}