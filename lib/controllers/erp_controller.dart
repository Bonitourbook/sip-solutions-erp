import 'package:flutter/material.dart';

class ErpController {
  final List<TransactionModel> transactions = <TransactionModel>[];

  void addTransaction(TransactionModel transaction) {
    transactions.add(transaction);
  }

  void removeTransaction(String id) {
    transactions.removeWhere((transaction) => transaction.id == id);
  }

  List<TransactionModel> getVisibleTransactions() {
    return List<TransactionModel>.from(transactions);
  }
}

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}
