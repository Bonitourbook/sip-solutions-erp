import 'package:flutter/material.dart';

import '../controllers/erp_controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key, required this.controller});

  final ErpController controller;

  @override
  Widget build(BuildContext context) {
    final transactions = controller.getVisibleTransactions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard ERP'),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(transaction.description),
                subtitle: Text(transaction.date.toLocal().toString()),
                trailing: Text(
                  '\$${transaction.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
