import 'package:flutter/material.dart';
import '../controllers/erp_controller.dart';
import '../models/transaction_model.dart';
import 'form_screen.dart';

class GenericModuleView extends StatefulWidget {
  final String moduleTitle;
  final String? filterType;

  const GenericModuleView({
    super.key,
    required this.moduleTitle,
    this.filterType,
  });

  @override
  State<GenericModuleView> createState() => _GenericModuleViewState();
}

class _GenericModuleViewState extends State<GenericModuleView> {
  List<TransactionModel> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadModuleData();
  }

  Future<void> loadModuleData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final list = await ErpController.instance.getTransactions(widget.filterType);
      if (!mounted) return;
      setState(() => items = list);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  String _moduleType() {
    final title = widget.moduleTitle.toLowerCase();
    if (title.contains('stock')) return 'COMPRA';
    if (title.contains('kardex')) return 'VENTA';
    if (title.contains('clientes')) return 'VENTA';
    return 'VENTA';
  }

  void _openNewForm() {
    final type = _moduleType();
    final title = type == 'COMPRA' ? 'Nuevo Producto' : 'Registrar Venta';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormScreen(title: title, type: type),
      ),
    ).then((_) => loadModuleData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05080F),
      appBar: AppBar(
        title: Text(widget.moduleTitle),
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: loadModuleData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadModuleData,
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
            : items.isEmpty
                ? Center(
                    child: Text(
                      'No hay registros en ${widget.moduleTitle}',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111827),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.client,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Modo: ${item.paymentMode} • Fecha: ${item.date}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tipo: ${item.type} • ${item.clientType}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '\$${item.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.greenAccent,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3b82f6),
        onPressed: _openNewForm,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

