class Order {
  final int? id;
  final String orderDate;
  final String status;
  final double totalAmount;
  final int isValidated;
  final int clientId;
  final int userId;
  final String? updatedAt;
  final int isSynced;

  Order({
    this.id,
    required this.orderDate,
    required this.status,
    required this.totalAmount,
    required this.isValidated,
    required this.clientId,
    required this.userId,
    this.updatedAt,
    this.isSynced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_date': orderDate,
      'status': status,
      'total_amount': totalAmount,
      'is_validated': isValidated,
      'client_id': clientId,
      'user_id': userId,
      'updated_at': updatedAt,
      'is_synced': isSynced,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      orderDate: map['order_date'],
      status: map['status'],
      totalAmount: (map['total_amount'] as num).toDouble(),
      isValidated: map['is_validated'],
      clientId: map['client_id'],
      userId: map['user_id'],
      updatedAt: map['updated_at'],
      isSynced: map['is_synced'] ?? 0,
    );
  }
}