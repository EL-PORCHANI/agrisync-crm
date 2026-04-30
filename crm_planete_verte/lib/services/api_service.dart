import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/client.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  Future<List<Client>> fetchClients() async {
    final response = await http.get(Uri.parse('$baseUrl/clients/'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Client.fromMap(json)).toList();
    } else {
      throw Exception('Failed to fetch clients');
    }
  }

  Future<Map<String, dynamic>?> sendClient(Client client) async {
    final response = await http.post(
      Uri.parse('$baseUrl/clients/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(client.toMap()),
    );

    print('CLIENT SYNC STATUS: ${response.statusCode}');
    print('CLIENT SYNC BODY: ${response.body}');

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    return null;
  }

  Future<Map<String, dynamic>?> fetchClientByPhone(String phone) async {
    final response = await http.get(
      Uri.parse('$baseUrl/clients/?phone=$phone'),
      headers: {'Content-Type': 'application/json'},
    );

    print('FETCH CLIENT STATUS: ${response.statusCode}');
    print('FETCH CLIENT BODY: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List && data.isNotEmpty) {
        return data.first;
      }

      return null;
    }

    return null;
  }
  Future<bool> updateClient(int serverId, Client client) async {
  final response = await http.put(
    Uri.parse('$baseUrl/clients/$serverId/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'name': client.name,
      'phone': client.phone,
      'address': client.address,
      'gps_location': client.gpsLocation,
      'latitude': client.latitude,
      'longitude': client.longitude,
      'pricing_category': client.pricingCategory,
      'zone_id': client.zoneId,
    }),
  );

  print('UPDATE CLIENT STATUS: ${response.statusCode}');
  print('UPDATE CLIENT BODY: ${response.body}');

  return response.statusCode == 200;
}
Future<http.Response> createOrder(Map<String, dynamic> orderData) async {
  final url = Uri.parse('$baseUrl/orders/');

  return await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(orderData),
  );
}

Future<http.Response> createInvoice(Map<String, dynamic> data) async {
  final url = Uri.parse('$baseUrl/invoices/');

  return await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(data),
  );
}

Future<http.Response> createVisit(Map<String, dynamic> visitData) async {
  final response = await http.post(
    Uri.parse('$baseUrl/visits/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(visitData),
  );

  return response;
}
}
