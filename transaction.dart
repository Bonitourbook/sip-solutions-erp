class TransactionModel {
  final int? id;
  final String type; // 'SALE' o 'PURCHASE'
  final int productId;
  final int quantity;
  final double totalPrice;
  final String date;

  TransactionModel({
    this.id,
    required this.type,
    required this.productId,
    required this.quantity,
    required this.totalPrice,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'productId': productId,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'date': date,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      type: map['type'],
      productId: map['productId'],
      quantity: map['quantity'],
      totalPrice: map['totalPrice'],
      date: map['date'],
    );
  }
}
