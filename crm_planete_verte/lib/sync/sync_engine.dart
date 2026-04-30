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

    print('CLIENTS TO SYNC: ${unsynced.length}');

    for (final item in unsynced) {
      try {
        final client = Client.fromMap(item);
        
        print('SYNCING CLIENT: ${client.phone}');

        if (client.phone == null || client.phone!.isEmpty) {
          print('Client skipped: missing phone');
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
            print('CLIENT SYNCED: ${client.phone}');
          }
        } else {
          final serverId = existingClient['id'];
          final success = await api.updateClient(serverId, client);

          if (success) {
            await db.updateClientServerId(
              item['id'] as int,
              serverId as int,
            );
            print('CLIENT UPDATED + SYNCED: ${client.phone}');
          }
        }
      } catch (e) {
        print('Client sync failed: $e');
      }
    }
  }

  Future<void> syncOrders() async {
    final unsynced = await db.getUnsyncedOrders();

    for (final item in unsynced) {
      final serverClientId = await db.getClientServerId(item['client_id'] as int);

      print("SYNCING ORDER: ${item['id']}");
      print("LOCAL CLIENT: ${item['client_id']}");
      print("SERVER CLIENT: $serverClientId");

      if (serverClientId == null) {
        print("ORDER SYNC SKIPPED: client has no server_id");
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

      print("ORDER SYNC STATUS: ${response.statusCode}");

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        await db.updateOrderServerId(
          item['id'] as int,
          responseData['id'] as int,
        );

        print("ORDER SERVER ID STORED: ${responseData['id']}");
      }
    }
  }

  Future<void> syncInvoices() async {
    final unsynced = await db.getUnsyncedInvoices();
    print("INVOICES TO SYNC: ${unsynced.length}");

    for (final item in unsynced) {
      final serverClientId = await db.getClientServerId(item['client_id']);
      final serverOrderId = await db.getOrderServerId(item['order_id']);

      print("SYNCING INVOICE: ${item['id']}");
      print("CLIENT SERVER ID: $serverClientId");
      print("ORDER SERVER ID: $serverOrderId");

      if (serverClientId == null || serverOrderId == null) {
        print("INVOICE SKIPPED: missing mapping");
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

      print("INVOICE STATUS: ${response.statusCode}");

      if (response.statusCode == 201) {
        await db.markAsSynced('invoices', item['id']);
        print("INVOICE SYNCED: ${item['id']}");
      }
    }
  }

  Future<void> syncVisits() async {
    final unsynced = await db.getUnsyncedVisits();

    print("VISITS TO SYNC: ${unsynced.length}");

    for (final item in unsynced) {
      final serverClientId = await db.getClientServerId(item['client_id']);

      if (serverClientId == null) {
        print("VISIT SKIPPED: client not synced");
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
      
      print("VISIT DATA: $visitData");
      

      final response = await api.createVisit(visitData);

      print("VISIT STATUS: ${response.statusCode}");
      print("VISIT BODY: ${response.body}");

      if (response.statusCode == 201) {
        await db.markAsSynced('visits', item['id']);
        print("VISIT SYNCED: ${item['id']}");
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