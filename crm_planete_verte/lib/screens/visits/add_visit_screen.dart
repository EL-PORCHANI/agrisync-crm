import 'package:flutter/material.dart';
import '../../models/client.dart';
import '../../models/visit.dart';
import '../../services/database_service.dart';
import 'package:geolocator/geolocator.dart';

class AddVisitScreen extends StatefulWidget {
  const AddVisitScreen({super.key});

  @override
  State<AddVisitScreen> createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitScreen> {
  Future<Position?> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // check if GPS is enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return null;
  }

  // check permission
  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.deniedForever) {
    return null;
  }

  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}
  List<Client> clients = [];
  Client? selectedClient;

  @override
  void initState() {
    super.initState();
    loadClients();
  }

  Future<void> loadClients() async {
    final loadedClients = await DatabaseService.instance.getClients();
    setState(() {
      clients = loadedClients;
    });
  }

  Future<void> saveVisit() async {
    if (selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a client')),
      );
      return;
    }

    final position = await getCurrentLocation();

    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to get location')),
      );
      return;
    }

    final clientLat = selectedClient!.latitude;
    final clientLng = selectedClient!.longitude;

    String validationStatus = 'pending';

    if (clientLat != null && clientLng != null) {
      final distance = calculateDistanceMeters(
        startLatitude: position.latitude,
        startLongitude: position.longitude,
        endLatitude: clientLat,
        endLongitude: clientLng,
      );

      validationStatus = distance <= 200 ? 'valid' : 'invalid';
    }

    final now = DateTime.now();

    final visit = Visit(
      visitDate: now.toIso8601String(),
      visitTime:
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      gpsLocation: 'Lat: ${position.latitude}, Lng: ${position.longitude}',
      latitude: position.latitude,
      longitude: position.longitude,
      validationStatus: validationStatus,
      clientId: selectedClient!.id!,
      userId: 1,
      updatedAt: now.toIso8601String(),
    );

    await DatabaseService.instance.insertVisit(visit);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Visit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<Client>(
              initialValue: selectedClient,
              decoration: const InputDecoration(
                labelText: 'Client',
                border: OutlineInputBorder(),
              ),
              items: clients.map((client) {
                return DropdownMenuItem<Client>(
                  value: client,
                  child: Text(client.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedClient = value;
                });
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveVisit,
                child: const Text('Save Visit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
    double calculateDistanceMeters({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}