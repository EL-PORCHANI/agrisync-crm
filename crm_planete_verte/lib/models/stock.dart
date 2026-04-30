class Stock {
  final int? id;
  final int availableQuantity;
  final int alertThreshold;
  final int productId;
  final int zoneId;
  final String? updatedAt;
  final int isSynced;

  Stock({
    this.id,
    required this.availableQuantity,
    required this.alertThreshold,
    required this.productId,
    required this.zoneId,
    this.updatedAt,
    this.isSynced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'available_quantity': availableQuantity,
      'alert_threshold': alertThreshold,
      'product_id': productId,
      'zone_id': zoneId,
      'updated_at': updatedAt,
      'is_synced': isSynced,
    };
  }

  factory Stock.fromMap(Map<String, dynamic> map) {
    return Stock(
      id: map['id'],
      availableQuantity: map['available_quantity'],
      alertThreshold: map['alert_threshold'],
      productId: map['product_id'],
      zoneId: map['zone_id'],
      updatedAt: map['updated_at'],
      isSynced: map['is_synced'] ?? 0,
    );
  }
}