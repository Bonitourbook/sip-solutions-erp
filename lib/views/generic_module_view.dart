import 'package:flutter/material.dart';
import '../controllers/erp_controller.dart';
import '../models/transaction_model.dart';

class GenericModuleView extends StatefulWidget {
  final String moduleTitle;
  final String? filterType;

  const GenericModuleView({super.key, required this.moduleTitle, this.filterType});

  @override
  State<GenericModuleView> createState() => _GenericModuleViewState();
}

class _GenericModuleViewState extends State<GenericModuleView> {
  List<TransactionModel> items = [];

  @override
  void initState() {
    super.initState();
    loadModuleData();
  }

  Future<void> loadModuleData() async {
    final list = await ErpController.instance.getTransactions(widget.filterType);
    setState(() {
      items = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moduleTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF0b0f19),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh, size: 20), onPressed: loadModuleData),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Text(
                'No hay registros en ${widget.moduleTitle}',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(item.client, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Modo: ${item.paymentMode} • ${item.date}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ),
                    trailing: Text('\$${item.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 15)),
                  ),
                );
              },
            ),
    );
  }
}
