import 'package:path/path.dart';
import '../models/client.dart';
import 'package:sqflite/sqflite.dart';
import '../models/product.dart';
import '../models/stock.dart';
import '../models/order.dart';
import '../models/order_line.dart';
import '../models/invoice.dart';
import '../models/visit.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'crm_planete_verte.db');

    print('==============================');
    print('FLUTTER DB PATH: $path');
    print('==============================');

    return await openDatabase(
      path,
      version: 2,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE zones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'sales_rep',
        zone_id INTEGER NOT NULL,
        updated_at TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (zone_id) REFERENCES zones(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        name TEXT NOT NULL,
        phone TEXT,
        address TEXT,
        gps_location TEXT,
        latitude REAL,
        longitude REAL,
        pricing_category TEXT,
        zone_id INTEGER NOT NULL,
        updated_at TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (zone_id) REFERENCES zones(id)
    )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        name TEXT NOT NULL,
        category TEXT,
        reference TEXT UNIQUE,
        current_price REAL NOT NULL DEFAULT 0,
        updated_at TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        stock_quantity INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE stocks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        available_quantity INTEGER NOT NULL DEFAULT 0,
        alert_threshold INTEGER NOT NULL DEFAULT 0,
        product_id INTEGER NOT NULL,
        zone_id INTEGER NOT NULL,
        updated_at TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (product_id) REFERENCES products(id),
        FOREIGN KEY (zone_id) REFERENCES zones(id),
        UNIQUE (product_id, zone_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        order_date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'draft',
        total_amount REAL NOT NULL DEFAULT 0,
        is_validated INTEGER NOT NULL DEFAULT 0,
        client_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        updated_at TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (client_id) REFERENCES clients(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE order_lines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        amount_due REAL NOT NULL DEFAULT 0,
        due_date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'up_to_date',
        delay_days INTEGER NOT NULL DEFAULT 0,
        client_id INTEGER NOT NULL,
        order_id INTEGER NOT NULL,
        updated_at TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (client_id) REFERENCES clients(id),
        FOREIGN KEY (order_id) REFERENCES orders(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE visits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        visit_date TEXT NOT NULL,
        visit_time TEXT NOT NULL,
        gps_location TEXT,
        latitude REAL,
        longitude REAL,
        validation_status TEXT NOT NULL DEFAULT 'pending',
        client_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        updated_at TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (client_id) REFERENCES clients(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('CREATE INDEX idx_clients_zone_id ON clients(zone_id)');
    await db.execute('CREATE INDEX idx_users_zone_id ON users(zone_id)');
    await db.execute('CREATE INDEX idx_stocks_product_id ON stocks(product_id)');
    await db.execute('CREATE INDEX idx_stocks_zone_id ON stocks(zone_id)');
    await db.execute('CREATE INDEX idx_orders_client_id ON orders(client_id)');
    await db.execute('CREATE INDEX idx_orders_user_id ON orders(user_id)');
    await db.execute('CREATE INDEX idx_order_lines_order_id ON order_lines(order_id)');
    await db.execute('CREATE INDEX idx_order_lines_product_id ON order_lines(product_id)');
    await db.execute('CREATE INDEX idx_invoices_client_id ON invoices(client_id)');
    await db.execute('CREATE INDEX idx_invoices_order_id ON invoices(order_id)');
    await db.execute('CREATE INDEX idx_visits_client_id ON visits(client_id)');
    await db.execute('CREATE INDEX idx_visits_user_id ON visits(user_id)');
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
  Future<int> insertZone(Map<String, dynamic> zone) async {
  final db = await database;
  return await db.insert('zones', zone);
}

Future<int> insertClient(Client client) async {
  final db = await database;
  return await db.insert('clients', client.toMap());
}

Future<List<Client>> getClients() async {
  final db = await database;
  final result = await db.query('clients', orderBy: 'id DESC');
  return result.map((e) => Client.fromMap(e)).toList();
}

Future<int> updateClient(int id, Client client) async {
  final db = await database;
  return await db.update(
    'clients',
    client.toMap(),
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<int> deleteClient(int id) async {
  final db = await database;
  return await db.delete(
    'clients',
    where: 'id = ?',
    whereArgs: [id],
  );
}
Future<void> deleteDatabaseFile() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'crm_planete_verte.db');
  await deleteDatabase(path);
}

Future<void> ensureDefaultZoneExists() async {
  final db = await database;

  final result = await db.query(
    'zones',
    where: 'id = ?',
    whereArgs: [1],
  );

  if (result.isEmpty) {
    await db.insert('zones', {
      'id': 1,
      'name': 'Default Zone',
      'description': 'Auto-created default zone',
    });
  }
}


Future<bool> clientPhoneExists(String phone) async {
  final db = await database;

  final result = await db.query(
    'clients',
    where: 'phone = ?',
    whereArgs: [phone],
    limit: 1,
  );

  return result.isNotEmpty;
}

Future<bool> clientPhoneExistsForOtherClient(String phone, int clientId) async {
  final db = await database;

  final result = await db.query(
    'clients',
    where: 'phone = ? AND id != ?',
    whereArgs: [phone, clientId],
    limit: 1,
  );

  return result.isNotEmpty;
}

Future<int> insertProduct(Product product) async {
  final db = await database;
  return await db.insert('products', product.toMap());
}

Future<List<Product>> getProducts() async {
  final db = await database;
  final result = await db.query('products', orderBy: 'id DESC');
  return result.map((e) => Product.fromMap(e)).toList();
}

Future<int> updateProduct(int id, Product product) async {
  final db = await database;
  return await db.update(
    'products',
    product.toMap(),
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<int> deleteProduct(int id) async {
  final db = await database;
  return await db.delete(
    'products',
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<bool> productReferenceExists(String reference) async {
  final db = await database;

  final result = await db.query(
    'products',
    where: 'reference = ?',
    whereArgs: [reference],
    limit: 1,
  );

  return result.isNotEmpty;
}

Future<void> seedProductsIfEmpty() async {
  final db = await database;

  final result = await db.query('products', limit: 1);

  if (result.isNotEmpty) return;

  final now = DateTime.now().toIso8601String();

  final products = [
    {
      'name': 'NPK Fertilizer 25kg',
      'category': 'Fertilizer',
      'reference': 'FERT-001',
      'current_price': 120.0,
      'stock_quantity': 50,
      'updated_at': now,
      'is_synced': 0,
    },
    {
      'name': 'Wheat Seeds Premium',
      'category': 'Seeds',
      'reference': 'SEED-001',
      'current_price': 75.5,
      'stock_quantity': 50,
      'updated_at': now,
      'is_synced': 0,
    },
    {
      'name': 'Organic Compost',
      'category': 'Soil',
      'reference': 'SOIL-001',
      'current_price': 45.0,
      'stock_quantity': 50,
      'updated_at': now,
      'is_synced': 0,
    },
    {
      'name': 'Pesticide A100',
      'category': 'Pesticide',
      'reference': 'PEST-001',
      'current_price': 89.9,
      'stock_quantity': 50,
      'updated_at': now,
      'is_synced': 0,
    },
  ];

  for (final product in products) {
    await db.insert('products', product);
  }
}

Future<int> insertStock(Stock stock) async {
  final db = await database;
  return await db.insert('stocks', stock.toMap());
}

Future<List<Stock>> getStockByZone(int zoneId) async {
  final db = await database;

  final result = await db.query(
    'stocks',
    where: 'zone_id = ?',
    whereArgs: [zoneId],
  );

  return result.map((e) => Stock.fromMap(e)).toList();
}

Future<Stock?> getStockForProduct(int productId, int zoneId) async {
  final db = await database;

  final result = await db.query(
    'stocks',
    where: 'product_id = ? AND zone_id = ?',
    whereArgs: [productId, zoneId],
    limit: 1,
  );

  if (result.isEmpty) return null;
  return Stock.fromMap(result.first);
}

Future<int> updateStockQuantity(int stockId, int newQuantity) async {
  final db = await database;

  return await db.update(
    'stocks',
    {
      'available_quantity': newQuantity,
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    },
    where: 'id = ?',
    whereArgs: [stockId],
  );
}

Future<void> seedStockIfEmpty() async {
  final db = await database;

  final result = await db.query('stocks', limit: 1);
  if (result.isNotEmpty) return;

  final products = await db.query('products');

  for (final p in products) {
    await db.insert('stocks', {
      'available_quantity': 50,
      'alert_threshold': 10,
      'product_id': p['id'],
      'zone_id': 1,
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    });
  }
}

Future<int> insertOrder(Order order) async {
  final db = await database;
  return await db.insert('orders', order.toMap());
}

Future<List<Order>> getOrders() async {
  final db = await database;

  final result = await db.query(
    'orders',
    orderBy: 'id DESC',
  );

  return result.map((e) => Order.fromMap(e)).toList();
}

Future<void> ensureDefaultUserExists() async {
  final db = await database;

  final result = await db.query(
    'users',
    where: 'id = ?',
    whereArgs: [1],
  );

  if (result.isEmpty) {
    await db.insert('users', {
      'id': 1,
      'name': 'Default Sales Rep',
      'email': 'sales@planeteverte.tn',
      'password': '123456',
      'role': 'sales_rep',
      'zone_id': 1,
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    });
  }
}

Future<int> insertOrderLine(OrderLine line) async {
  final db = await database;
  return await db.insert('order_lines', line.toMap());
}

Future<bool> isStockAvailable(int productId, int zoneId, int requestedQty) async {
  final stock = await getStockForProduct(productId, zoneId);

  if (stock == null) return false;

  return stock.availableQuantity >= requestedQty;
}

Future<void> decreaseStock(int productId, int zoneId, int quantity) async {
  final db = await database;

  final stock = await getStockForProduct(productId, zoneId);

  if (stock == null) return;

  final newQuantity = stock.availableQuantity - quantity;

  await db.update(
    'stocks',
    {
      'available_quantity': newQuantity,
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    },
    where: 'id = ?',
    whereArgs: [stock.id],
  );
}

Future<int> insertInvoice(Invoice invoice) async {
  final db = await database;
  return await db.insert('invoices', invoice.toMap());
}

Future<List<Invoice>> getInvoices() async {
  final db = await database;
  final result = await db.query('invoices', orderBy: 'id DESC');
  return result.map((e) => Invoice.fromMap(e)).toList();
}

Future<List<Invoice>> getUnpaidInvoices() async {
  final db = await database;
  final result = await db.query(
    'invoices',
    where: 'status != ?',
    whereArgs: ['paid'],
    orderBy: 'id DESC',
  );
  return result.map((e) => Invoice.fromMap(e)).toList();
}

Future<int> updateInvoiceStatus(int id, String status, int delayDays) async {
  final db = await database;

  return await db.update(
    'invoices',
    {
      'status': status,
      'delay_days': delayDays,
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> refreshInvoiceStatuses() async {
  final db = await database;

  final result = await db.query(
    'invoices',
    where: 'status != ?',
    whereArgs: ['paid'],
  );

  final now = DateTime.now();

  for (final row in result) {
    final id = row['id'] as int;
    final dueDate = DateTime.parse(row['due_date'] as String);

    final difference = now.difference(dueDate).inDays;

    String newStatus = 'up_to_date';
    int delayDays = 0;

    if (difference > 0) {
      delayDays = difference;

      if (difference <= 7) {
        newStatus = 'late';
      } else {
        newStatus = 'critical';
      }
    }

    await db.update(
      'invoices',
      {
        'status': newStatus,
        'delay_days': delayDays,
        'updated_at': DateTime.now().toIso8601String(),
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

Future<int> insertVisit(Visit visit) async {
  final db = await database;
  return await db.insert('visits', visit.toMap());
}

Future<List<Visit>> getVisits() async {
  final db = await database;
  final result = await db.query('visits', orderBy: 'id DESC');
  return result.map((e) => Visit.fromMap(e)).toList();
}

Future<List<Map<String, dynamic>>> getUnsyncedClients() async {
  final db = await database;
  return await db.query('clients', where: 'is_synced = ?', whereArgs: [0]);
}

Future<List<Map<String, dynamic>>> getUnsyncedOrders() async {
  final db = await database;
  return await db.query('orders', where: 'is_synced = ?', whereArgs: [0]);
}

Future<List<Map<String, dynamic>>> getUnsyncedInvoices() async {
  final db = await database;
  return await db.query('invoices', where: 'is_synced = ?', whereArgs: [0]);
}

Future<List<Map<String, dynamic>>> getUnsyncedVisits() async {
  final db = await database;
  return await db.query('visits', where: 'is_synced = ?', whereArgs: [0]);
}

Future<List<Map<String, dynamic>>> getUnsyncedStocks() async {
  final db = await database;
  return await db.query('stocks', where: 'is_synced = ?', whereArgs: [0]);
}

Future<void> markAsSynced(String tableName, int id) async {
  final db = await database;

  await db.update(
    tableName,
    {
      'is_synced': 1,
      'updated_at': DateTime.now().toIso8601String(),
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<int> countUnsyncedClients() async {
  final db = await database;
  final result = await db.rawQuery(
    'SELECT COUNT(*) as count FROM clients WHERE is_synced = 0',
  );
  return result.first['count'] as int;
}

Future<int> countUnsyncedOrders() async {
  final db = await database;
  final result = await db.rawQuery(
    'SELECT COUNT(*) as count FROM orders WHERE is_synced = 0',
  );
  return result.first['count'] as int;
}

Future<int> countUnsyncedInvoices() async {
  final db = await database;
  final result = await db.rawQuery(
    'SELECT COUNT(*) as count FROM invoices WHERE is_synced = 0',
  );
  return result.first['count'] as int;
}

Future<int> countUnsyncedVisits() async {
  final db = await database;
  final result = await db.rawQuery(
    'SELECT COUNT(*) as count FROM visits WHERE is_synced = 0',
  );
  return result.first['count'] as int;
}

Future<int> countUnsyncedStocks() async {
  final db = await database;
  final result = await db.rawQuery(
    'SELECT COUNT(*) as count FROM stocks WHERE is_synced = 0',
  );
  return result.first['count'] as int;
}

Future<int?> getClientServerId(int localId) async {
  final dbClient = await database;
  final result = await dbClient.query(
    'clients',
    columns: ['server_id'],
    where: 'id = ?',
    whereArgs: [localId],
  );

  if (result.isNotEmpty) {
    return result.first['server_id'] as int?;
  }
  return null;
}

Future<int?> getOrderServerId(int localId) async {
  final dbClient = await database;
  final result = await dbClient.query(
    'orders',
    columns: ['server_id'],
    where: 'id = ?',
    whereArgs: [localId],
  );

  if (result.isNotEmpty) {
    return result.first['server_id'] as int?;
  }
  return null;
}

Future<void> updateOrderServerId(int localOrderId, int serverOrderId) async {
  final dbClient = await database;

  await dbClient.update(
    'orders',
    {
      'is_synced': 1,
      'server_id': serverOrderId,
    },
    where: 'id = ?',
    whereArgs: [localOrderId],
  );
}

Future<void> updateClientServerId(int localClientId, int serverClientId) async {
  final dbClient = await database;

  await dbClient.update(
    'clients',
    {
      'is_synced': 1,
      'server_id': serverClientId,
    },
    where: 'id = ?',
    whereArgs: [localClientId],
  );
}

Future<List<Map<String, dynamic>>> getOrderLines(int orderId) async {
  final dbClient = await database;

  return await dbClient.query(
    'order_lines',
    where: 'order_id = ?',
    whereArgs: [orderId],
  );
}

Future<String?> getProductName(int productId) async {
  final dbClient = await database;

  final result = await dbClient.query(
    'products',
    columns: ['name'],
    where: 'id = ?',
    whereArgs: [productId],
  );

  if (result.isNotEmpty) {
    return result.first['name'] as String?;
  }
  return null;
}

Future<int> getTotalClients() async {
  final dbClient = await database;
  final result = await dbClient.rawQuery('SELECT COUNT(*) as count FROM clients');
  return Sqflite.firstIntValue(result) ?? 0;
}

Future<int> getTotalOrders() async {
  final dbClient = await database;
  final result = await dbClient.rawQuery('SELECT COUNT(*) as count FROM orders');
  return Sqflite.firstIntValue(result) ?? 0;
}

Future<double> getTotalRevenue() async {
  final dbClient = await database;
  final result = await dbClient.rawQuery('SELECT SUM(total_amount) as total FROM orders');
  return result.first['total'] as double? ?? 0.0;
}


Future<int> getTodayVisits() async {
  final dbClient = await database;
  final today = DateTime.now().toIso8601String().split('T')[0];

  final result = await dbClient.rawQuery(
    "SELECT COUNT(*) as count FROM visits WHERE visit_date = ?",
    [today],
  );

  return Sqflite.firstIntValue(result) ?? 0;
}

Future<List<Map<String, dynamic>>> getRevenueByMonth() async {
  final dbClient = await database;

  return await dbClient.rawQuery('''
    SELECT 
      substr(order_date, 1, 7) as month,
      SUM(total_amount) as total
    FROM orders
    GROUP BY month
    ORDER BY month ASC
  ''');
}

Future<Map<String, dynamic>?> getTopClient() async {
  final dbClient = await database;

  final result = await dbClient.rawQuery('''
    SELECT clients.name, SUM(orders.total_amount) as total
    FROM orders
    JOIN clients ON orders.client_id = clients.id
    GROUP BY clients.id
    ORDER BY total DESC
    LIMIT 1
  ''');

  if (result.isNotEmpty) return result.first;
  return null;
}

Future<int> getLowStockCount() async {
  final dbClient = await database;

  final result = await dbClient.rawQuery('''
    SELECT COUNT(*) as count
    FROM stocks
    WHERE available_quantity <= alert_threshold
  ''');

  return Sqflite.firstIntValue(result) ?? 0;
}

}