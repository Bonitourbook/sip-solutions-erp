import 'package:flutter/material.dart';
import 'controllers/erp_controller.dart';
import 'models/transaction_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ErpApp());
}

class ErpApp extends StatelessWidget {
  const ErpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIP Solutions ERP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0b0f19),
        cardColor: const Color(0xFF111827),
        primaryColor: Colors.blueAccent,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<TransactionModel>> _transactionsFuture;
  double _totalVentas = 0.0;
  double _totalCompras = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _transactionsFuture = ErpController.instance.getTransactions();
    ErpController.instance.getSum('VENTA').then((val) => setState(() => _totalVentas = val));
    ErpController.instance.getSum('COMPRA').then((val) => setState(() => _totalCompras = val));
  }

  @override
  Widget build(BuildContext context) {
    double rentabilidad = _totalVentas - _totalCompras;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SIP Solutions ERP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.grey),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BOTONES DE ACCIÓN PRINCIPAL (Motor del ERP)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Nueva Venta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    onPressed: () {
                      // Acción para nueva venta
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text('Nueva Compra', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    onPressed: () {
                      // Acción para nueva compra
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // TARJETAS DE MÉTRICAS FINANCIERAS
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('VENTAS TOTALES', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('${_totalVentas.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        const Text('+ Activo', style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('BENEFICIO NETO', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('${rentabilidad.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                        const SizedBox(height: 4),
                        const Text('Sales - Purchases', style: TextStyle(color: Colors.green, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // SECCIÓN DE TRANSACCIONES / HISTORIAL RECIENTE
            const Text('Transacciones & Kardex', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            
            SizedBox(
              height: 350,
              child: FutureBuilder<List<TransactionModel>>(
                future: _transactionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay registros en el sistema.'));
                  }

                  final transactions = snapshot.data!;
                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111827),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(tx.client, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          subtitle: Text('Tipo: ${tx.type} | Fecha: ${tx.date}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          trailing: Text(
                            '${tx.amount.toStringAsFixed(2)} €',
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 16, 
                              color: tx.type == 'VENTA' ? Colors.greenAccent : (tx.type == 'COMPRA' ? Colors.orangeAccent : Colors.blueAccent)
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
