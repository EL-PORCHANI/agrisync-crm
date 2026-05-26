class Product {
  final int? id;
  final String name;
  final String? category;
  final String? reference;
  final double currentPrice;
  final String? updatedAt;
  final int isSynced;
  final int stockQuantity;

  Product({
    this.id,
    required this.name,
    this.category,
    this.reference,
    required this.currentPrice,
    this.updatedAt,
    this.isSynced = 0,
    required this.stockQuantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'reference': reference,
      'current_price': currentPrice,
      'updated_at': updatedAt,
      'is_synced': isSynced,
      'stock_quantity': stockQuantity,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      reference: map['reference'],
      currentPrice: (map['current_price'] as num).toDouble(),
      updatedAt: map['updated_at'],
      isSynced: map['is_synced'] ?? 0,
      stockQuantity: map['stock_quantity'] ?? 0,
    );
  }
}