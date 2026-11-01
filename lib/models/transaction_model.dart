class TransactionModel {
  TransactionModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
  });

  final String id;
  final String description;
  final double amount;
  final DateTime date;

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'amount': amount,
        'date': date.toIso8601String(),
      };
}
