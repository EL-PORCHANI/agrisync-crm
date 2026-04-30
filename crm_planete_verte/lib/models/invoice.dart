class Invoice {
  final int? id;
  final double amountDue;
  final String dueDate;
  final String status;
  final int delayDays;
  final int clientId;
  final int orderId;
  final String? updatedAt;
  final int isSynced;

  Invoice({
    this.id,
    required this.amountDue,
    required this.dueDate,
    required this.status,
    required this.delayDays,
    required this.clientId,
    required this.orderId,
    this.updatedAt,
    this.isSynced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount_due': amountDue,
      'due_date': dueDate,
      'status': status,
      'delay_days': delayDays,
      'client_id': clientId,
      'order_id': orderId,
      'updated_at': updatedAt,
      'is_synced': isSynced,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      amountDue: (map['amount_due'] as num).toDouble(),
      dueDate: map['due_date'],
      status: map['status'],
      delayDays: map['delay_days'],
      clientId: map['client_id'],
      orderId: map['order_id'],
      updatedAt: map['updated_at'],
      isSynced: map['is_synced'] ?? 0,
    );
  }
}