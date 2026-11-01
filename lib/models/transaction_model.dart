class TransactionModel {
  final int? id;
  final String type;
  final String client;
  final String clientType;
  final double amount;
  final String status;
  final String date;

  TransactionModel({
    this.id,
    required this.type,
    required this.client,
    required this.clientType,
    required this.amount,
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
      amount: map['amount'],
      status: map['status'],
      date: map['date'],
    );
  }
}
