class TransactionModel {
  final int? id;
  final String type;
  final String client;
  final String clientType;
  final double amount;
  final double paidAmount;
  final String paymentMode;
  final bool hasDelivery;
  final String status;
  final String date;

  TransactionModel({
    this.id,
    required this.type,
    required this.client,
    required this.clientType,
    required this.amount,
    required this.paidAmount,
    required this.paymentMode,
    required this.hasDelivery,
    required this.status,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'client': client,
      'client_type': clientType,
      'amount': amount,
      'paid_amount': paidAmount,
      'payment_mode': paymentMode,
      'has_delivery': hasDelivery ? 1 : 0,
      'status': status,
      'date': date,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      type: map['type'],
      client: map['client'],
      clientType: map['client_type'],
      amount: map['amount'] ?? 0.0,
      paidAmount: map['paid_amount'] ?? 0.0,
      paymentMode: map['payment_mode'] ?? 'Contado',
      hasDelivery: map['has_delivery'] == 1,
      status: map['status'] ?? 'Activa',
      date: map['date'] ?? '',
    );
  }
}
