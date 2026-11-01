import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ErpJuanApp());
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('erp_juan.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        client TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertTransaction(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('transactions', row);
  }

  Future<List>> getTransactions() async {
    final db = await instance.database;
    return await db.query('transactions', orderBy: 'id DESC');
  }

  Future<double> getTotalByType(String type) async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT SUM(amount) as total FROM transactions WHERE type = ?', [type]);
    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }
}

class ErpJuanApp extends StatelessWidget {
  const ErpJuanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ERP Juan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0b0f19),
        primaryColor: const Color(0xFF3b82f6),
        cardColor: const Color(0xFF111827),
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
  double totalVentas = 0.0;
  double totalCompras = 0.0;
  List> recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final ventas = await DatabaseHelper.instance.getTotalByType('VENTA');
    final compras = await DatabaseHelper.instance.getTotalByType('COMPRA');
    final txs = await DatabaseHelper.instance.getTransactions();
    setState(() {
      totalVentas = ventas;
      totalCompras = compras;
      recentTransactions = txs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0b0f19),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3b82f6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('EJ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('ERP Juan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('• Sistema Comercial Activo', style: TextStyle(fontSize: 11, color: Colors.green)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Botones Principales de Motor (Protagonistas absolutos: Nueva Venta y Nueva Compra)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NewTransactionScreen(type: 'VENTA')),
                      );
                      _loadData();
                    },
                    icon: const Icon(Icons.point_of_sale, size: 24),
                    label: const Text('Nueva Venta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10b981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NewTransactionScreen(type: 'COMPRA')),
                      );
                      _loadData();
                    },
                    icon: const Icon(Icons.shopping_cart_outlined, size: 24),
                    label: const Text('Nueva Compra', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3b82f6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tarjetas de Métricas de Negocio
            Row(
              children: [
                Expanded(child: _buildMetricCard('Total Ventas', '\$${totalVentas.toStringAsFixed(2)}', Colors.greenAccent, Icons.trending_up)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard('Total Compras', '\$${totalCompras.toStringAsFixed(2)}', Colors.blueAccent, Icons.inventory)),
              ],
            ),
            const SizedBox(height: 24),

            // Historial de Operaciones Registradas
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Registro de Operaciones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  recentTransactions.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text('No hay transacciones registradas aún.', style: TextStyle(color: Colors.grey)),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentTransactions.length,
                          itemBuilder: (context, index) {
                            final tx = recentTransactions[index];
                            final isVenta = tx['type'] == 'VENTA';
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: isVenta ? Colors.green.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                                child: Icon(isVenta ? Icons.arrow_downward : Icons.arrow_upward, color: isVenta ? Colors.greenAccent : Colors.blueAccent),
                              ),
                              title: Text(tx['client'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(tx['date'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              trailing: Text(
                                '${isVenta ? '+' : '-'}\$${tx['amount'].toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold, color: isVenta ? Colors.greenAccent : Colors.white),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color accentColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              Icon(icon, color: accentColor, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}

class NewTransactionScreen extends StatefulWidget {
  final String type;
  const NewTransactionScreen({super.key, required this.type});

  @override
  State<NewTransactionScreen> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  final _clientController = TextEditingController();
  final _amountController = TextEditingController();

  void _saveTransaction() async {
    final client = _clientController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (client.isEmpty || amount <= 0) return;

    await DatabaseHelper.instance.insertTransaction({
      'type': widget.type,
      'client': client,
      'amount': amount,
      'date': DateTime.now().toString().substring(0, 16),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isVenta = widget.type == 'VENTA';
    return Scaffold(
      appBar: AppBar(
        title: Text(isVenta ? 'Registrar Nueva Venta' : 'Registrar Nueva Compra'),
        backgroundColor: const Color(0xFF111827),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _clientController,
              decoration: const InputDecoration(
                labelText: 'Cliente / Proveedor',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monto (\$)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: isVenta ? const Color(0xFF10b981) : const Color(0xFF3b82f6),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Guardar ${isVenta ? 'Venta' : 'Compra'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
