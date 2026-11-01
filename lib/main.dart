import 'package:flutter/material.dart';

void main() {
  runApp(const ErpJuanApp());
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

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
              child: const Text('S', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('ERP Juan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('• Cuentas & Alertas Activas', style: TextStyle(fontSize: 12, color: Colors.green)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF3b82f6)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Alerta de deudas
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1f161a),
                border: Border.all(color: Colors.red.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('1 Deuda(s) Vencida(s) · Cobrar \$7550', style: TextStyle(fontSize: 13, color: Colors.redAccent)),
                    ],
                  ),
                  Text('Exportar', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tarjetas de métricas principales (Grid 2x2)
            Row(
              children: [
                Expanded(child: _buildMetricCard('Por Cobrar', '\$7,550.00', '1 Vencidas (\$3000)', Colors.redAccent, Icons.schedule)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard('Ingresos', '\$245,310', '+12.7% este mes', Colors.blueAccent, Icons.attach_money)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildMetricCard('Valor Stock', '\$54,450', 'En inventario activo', Colors.blueGrey, Icons.inventory_2)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard('Stock Bajo', '2 Prod.', 'Requieren reposición', Colors.orangeAccent, Icons.warning_amber)),
              ],
            ),
            const SizedBox(height: 20),

            // Próximos Vencimientos
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Próximos Vencimientos de Cobro', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                      Text('Ver Todo', style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDebtItem('Olivia Chen (TechCorp)', 'Vencida por 2 días', '\$3000.00', true),
                  const Divider(color: Colors.white12),
                  _buildDebtItem('Liam Brown (OmniSoft)', '¡Vence Hoy!', '\$3200.00', false),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Gráfico de Rendimiento de Ventas
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Rendimiento de Ventas', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('USD (\$)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const Text('Ingresos vs Cuentas cobradas', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 140,
                    child: Center(
                      child: Text(
                        '📈 [Gráfico de Tendencia Activo]',
                        style: TextStyle(color: Colors.blue.shade300, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, Color accentColor, IconData icon) {
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
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 11, color: accentColor)),
        ],
      ),
    );
  }

  Widget _buildDebtItem(String name, String status, String amount, bool isOverdue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isOverdue ? Colors.red.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(status, style: TextStyle(fontSize: 10, color: isOverdue ? Colors.redAccent : Colors.orangeAccent)),
              ),
            ],
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 15)),
        ],
      ),
    );
  }
}