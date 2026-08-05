import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/client.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Client>> fetchClients() async {
    final response = await http.get(
      Uri.parse('$baseUrl/clients/'),
      headers: await _authHeaders(),
    );
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
      headers: await _authHeaders(),
      body: jsonEncode(client.toMap()),
    );


    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    return null;
  }

  Future<Map<String, dynamic>?> fetchClientByPhone(String phone) async {
    final response = await http.get(
      Uri.parse('$baseUrl/clients/?phone=$phone'),
      headers: await _authHeaders(),
    );



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
      headers: await _authHeaders(),
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

    return response.statusCode == 200;
  }

  Future<http.Response> createOrder(Map<String, dynamic> orderData) async {
    final url = Uri.parse('$baseUrl/orders/');

    return await http.post(
      url,
      headers: await _authHeaders(),
      body: jsonEncode(orderData),
    );
  }

  Future<http.Response> createInvoice(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/invoices/');

    return await http.post(
      url,
      headers: await _authHeaders(),
      body: jsonEncode(data),
    );
  }

  Future<http.Response> createVisit(Map<String, dynamic> visitData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/visits/'),
      headers: await _authHeaders(),
      body: jsonEncode(visitData),
    );

    return response;
  }

  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/token/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('access_token', data['access']);
      await prefs.setString('refresh_token', data['refresh']);
      await prefs.setString('username', username);

      return true;
    }

    return false;
  }

  Future<String> getStoredUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'Commercial';
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('username');
  }
}


