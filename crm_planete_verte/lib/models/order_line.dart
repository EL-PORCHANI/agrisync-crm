class OrderLine {
  final int? id;
  final int quantity;
  final double unitPrice;
  final int orderId;
  final int productId;

  OrderLine({
    this.id,
    required this.quantity,
    required this.unitPrice,
    required this.orderId,
    required this.productId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quantity': quantity,
      'unit_price': unitPrice,
      'order_id': orderId,
      'product_id': productId,
    };
  }

  factory OrderLine.fromMap(Map<String, dynamic> map) {
    return OrderLine(
      id: map['id'],
      quantity: map['quantity'],
      unitPrice: map['unit_price'],
      orderId: map['order_id'],
      productId: map['product_id'],
    );
  }
}