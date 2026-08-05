import 'package:flutter/foundation.dart';

import '../models/client.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import 'dart:convert';

class SyncEngine {
  final DatabaseService db = DatabaseService.instance;
  final ApiService api = ApiService();

  Future<void> syncAll() async {
    await syncClients();
    await syncOrders();
    await syncInvoices();
    await syncVisits();
    await syncStocks();
  }

  Future<void> syncClients() async {
    final unsynced = await db.getUnsyncedClients();

    debugPrint('CLIENTS TO SYNC: ${unsynced.length}');

    for (final item in unsynced) {
      try {
        final client = Client.fromMap(item);
        
        debugPrint('SYNCING CLIENT: ${client.phone}');

        if (client.phone == null || client.phone!.isEmpty) {
          debugPrint('Client skipped: missing phone');
          continue;
        }

        final existingClient = await api.fetchClientByPhone(client.phone!);
        if (existingClient == null) {
          final createdClient = await api.sendClient(client);

          if (createdClient != null) {
            await db.updateClientServerId(
              item['id'] as int,
              createdClient['id'] as int,
            );
            debugPrint('CLIENT SYNCED: ${client.phone}');
          }
        } else {
          final serverId = existingClient['id'];
          final success = await api.updateClient(serverId, client);

          if (success) {
            await db.updateClientServerId(
              item['id'] as int,
              serverId as int,
            );
            debugPrint('CLIENT UPDATED + SYNCED: ${client.phone}');
          }
        }
      } catch (e) {
        debugPrint('Client sync failed: $e');
      }
    }
  }

  Future<void> syncOrders() async {
    final unsynced = await db.getUnsyncedOrders();

    for (final item in unsynced) {
      final serverClientId = await db.getClientServerId(item['client_id'] as int);

      debugPrint("SYNCING ORDER: ${item['id']}");
      debugPrint("LOCAL CLIENT: ${item['client_id']}");
      debugPrint("SERVER CLIENT: $serverClientId");

      if (serverClientId == null) {
        debugPrint("ORDER SYNC SKIPPED: client has no server_id");
        continue;
      }


      
      final linesFromDb = await db.getOrderLines(item['id'] as int);

      final List<Map<String, dynamic>> lines = [];

      for (final line in linesFromDb) {
        final productName = await db.getProductName(line['product_id'] as int);

        lines.add({
          "product_name": productName ?? "Unknown Product",
          "quantity": line['quantity'],
          "price": line['unit_price'],
        });
      }

      final orderData = {
        "client": serverClientId,
        "total_amount": item['total_amount'],
        "status": item['status'],
        "lines": lines,
      };


      final response = await api.createOrder(orderData);

      debugPrint("ORDER SYNC STATUS: ${response.statusCode}");

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        await db.updateOrderServerId(
          item['id'] as int,
          responseData['id'] as int,
        );

        debugPrint("ORDER SERVER ID STORED: ${responseData['id']}");
      }
    }
  }

  Future<void> syncInvoices() async {
    final unsynced = await db.getUnsyncedInvoices();
    debugPrint("INVOICES TO SYNC: ${unsynced.length}");

    for (final item in unsynced) {
      final serverClientId = await db.getClientServerId(item['client_id']);
      final serverOrderId = await db.getOrderServerId(item['order_id']);

      debugPrint("SYNCING INVOICE: ${item['id']}");
      debugPrint("CLIENT SERVER ID: $serverClientId");
      debugPrint("ORDER SERVER ID: $serverOrderId");

      if (serverClientId == null || serverOrderId == null) {
        debugPrint("INVOICE SKIPPED: missing mapping");
        continue;
      }

      // date formatting here
      final rawDate = item['due_date'].toString();
      final formattedDate = rawDate.split('T')[0].split(' ')[0];
      // map starts here
      final invoiceData = {
        "amount_due": item['amount_due'],
        "due_date": formattedDate,
        "status": item['status'],
        "delay_days": item['delay_days'],
        "client": serverClientId,
        "order": serverOrderId,
      };


      final response = await api.createInvoice(invoiceData);

      debugPrint("INVOICE STATUS: ${response.statusCode}");

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final serverInvoiceId = responseData['id'] as int?;

        if (serverInvoiceId != null) {
          await db.updateInvoiceServerId(item['id'] as int, serverInvoiceId);
        } else {
          await db.markAsSynced('invoices', item['id'] as int);
        }
        debugPrint("INVOICE SYNCED: ${item['id']}");
      }
    }
  }

  Future<void> syncVisits() async {
    final unsynced = await db.getUnsyncedVisits();

    debugPrint("VISITS TO SYNC: ${unsynced.length}");

    for (final item in unsynced) {
      final serverClientId = await db.getClientServerId(item['client_id']);

      if (serverClientId == null) {
        debugPrint("VISIT SKIPPED: client not synced");
        continue;
      }

      final rawDate = item['visit_date'].toString();
      final formattedDate = rawDate.split('T')[0];
      final rawTime = item['visit_time'].toString();
      final formattedTime = rawTime.length == 5 ? "$rawTime:00" : rawTime;

      final visitData = {
        "visit_date": formattedDate,
        "visit_time": formattedTime,
        "gps_location": item['gps_location'],
        "latitude": item['latitude'],
        "longitude": item['longitude'],
        "validation_status": item['validation_status'],
        "client": serverClientId,
        "user": 1,
      };
      
      debugPrint("VISIT DATA: $visitData");
      

      final response = await api.createVisit(visitData);

      debugPrint("VISIT STATUS: ${response.statusCode}");
      debugPrint("VISIT BODY: ${response.body}");

      if (response.statusCode == 201) {
        await db.markAsSynced('visits', item['id']);
        debugPrint("VISIT SYNCED: ${item['id']}");
      }
      
    }
  }

  Future<void> syncStocks() async {
    final unsynced = await db.getUnsyncedStocks();

    for (final item in unsynced) {
      await db.markAsSynced('stocks', item['id'] as int);
    }
  }
}
