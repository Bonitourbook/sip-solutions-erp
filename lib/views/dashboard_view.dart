import 'package:flutter/material.dart';
import '../controllers/erp_controller.dart';
import '../models/transaction_model.dart';
import 'form_screen.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  double totalVentas = 0.0;
  double totalCompras = 0.0;
  double totalCuentasPorCobrar = 0.0;
  List<TransactionModel> items = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final results = await Future.wait([
      ErpController.instance.getSum('VENTA'),
      ErpController.instance.getSum('COMPRA'),
      ErpController.instance.getPendingReceivablesTotal(),
      ErpController.instance.getTransactions(),
    ]);

    if (!mounted) return;

    setState(() {
      totalVentas = results[0] as double;
      totalCompras = results[1] as double;
      totalCuentasPorCobrar = results[2] as double;
      items = results[3] as List<TransactionModel>;
    });
  }

  void _showAddOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          title: const Text(
            'MENÚ RÁPIDO ERP',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMenuTile(
                context,
                icon: Icons.request_quote,
                color: Colors.redAccent,
                title: 'Nueva Cuenta por Cobrar',
                type: 'COBRO',
              ),
              Divider(color: Colors.white.withOpacity(0.06), height: 1),
              _buildMenuTile(
                context,
                icon: Icons.shopping_cart_outlined,
                color: Colors.greenAccent,
                title: 'Registrar Venta',
                type: 'VENTA',
              ),
              Divider(color: Colors.white.withOpacity(0.06), height: 1),
              _buildMenuTile(
                context,
                icon: Icons.inventory_2_outlined,
                color: Colors.blueAccent,
                title: 'Nuevo Producto',
                type: 'PRODUCTO',
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuTile(BuildContext context, {required IconData icon, required Color color, required String title, required String type}) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FormScreen(title: title, type: type)),
        ).then((_) => loadData());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double rentabilidad = totalVentas - totalCompras;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0b0f19),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF3b82f6), borderRadius: BorderRadius.circular(8)),
              child: const Text('S', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('ERP Juan v1.0', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('• Cuentas & Alertas Activas', style: TextStyle(fontSize: 10, color: Colors.greenAccent)),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFF1e293b), borderRadius: BorderRadius.circular(6)),
            child: const Text('Por Juan', style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold)),
          ),
          IconButton(icon: const Icon(Icons.refresh, size: 20), onPressed: loadData),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: const Color(0xFF3b82f6), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
            onPressed: () => _showAddOptions(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (totalCuentasPorCobrar > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cuentas por cobrar',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '\$${totalCuentasPorCobrar.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rentabilidad', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 2),
                  const Text('Total ventas vs Total compras', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 12),
                  Text('\$${rentabilidad.toStringAsFixed(2)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: rentabilidad >= 0 ? Colors.greenAccent : Colors.redAccent)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: MetricCard(title: 'Ingresos Ventas', val: '\$${totalVentas.toStringAsFixed(2)}', subtitle: 'Registradas en sistema', color: Colors.blueAccent, icon: Icons.attach_money)),
                const SizedBox(width: 12),
                Expanded(child: MetricCard(title: 'Total Compras', val: '\$${totalCompras.toStringAsFixed(2)}', subtitle: 'Gastos de inventario', color: Colors.orangeAccent, icon: Icons.shopping_cart)),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Historial Operativo General', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                  const SizedBox(height: 12),
                  if (items.isEmpty)
                    const Text('No hay registros todavía. Usa el botón "+" superior para agregar.', style: TextStyle(color: Colors.grey, fontSize: 12))
                  else
                    ...items.map((tx) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tx.client, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                                Text('${tx.type} · ${tx.clientType} ${tx.hasDelivery ? "(Con Delivery)" : ""}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Text('\$${tx.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 14)),
                        ],
                      ),
                    )),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String val;
  final String subtitle;
  final Color color;
  final IconData icon;

  const MetricCard({super.key, required this.title, required this.val, required this.subtitle, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 9, color: color)),
        ],
      ),
    );
  }
}
