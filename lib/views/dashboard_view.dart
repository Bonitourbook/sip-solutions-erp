import 'package:flutter/material.dart';
import '../controllers/erp_controller.dart';
import '../models/transaction_model.dart';
import 'form_screen.dart';
import 'generic_module_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  double totalVentas = 0.0;
  double totalCompras = 0.0;
  List<TransactionModel> items = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ErpController.instance.getSum('VENTA'),
        ErpController.instance.getSum('COMPRA'),
        ErpController.instance.getTransactions(),
      ]);

      if (!mounted) return;

      setState(() {
        totalVentas = results[0] as double;
        totalCompras = results[1] as double;
        items = results[2] as List<TransactionModel>;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'No se pudieron cargar los datos. Intenta nuevamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _openModule(String title, String? filterType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GenericModuleView(
          moduleTitle: title,
          filterType: filterType,
        ),
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white10),
          ),
          title: const Text(
            'MENÚ RÁPIDO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.request_quote_rounded, color: Colors.redAccent),
                  title: const Text('Nueva Cuenta por Cobrar', style: TextStyle(color: Colors.white, fontSize: 13)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FormScreen(
                          title: 'Nueva Cuenta por Cobrar',
                          type: 'COBRO',
                        ),
                      ),
                    ).then((_) => loadData());
                  },
                ),
                const Divider(color: Colors.white10),
                ListTile(
                  leading: const Icon(Icons.shopping_cart_rounded, color: Colors.greenAccent),
                  title: const Text('Registrar Venta', style: TextStyle(color: Colors.white, fontSize: 13)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FormScreen(
                          title: 'Registrar Venta',
                          type: 'VENTA',
                        ),
                      ),
                    ).then((_) => loadData());
                  },
                ),
                const Divider(color: Colors.white10),
                ListTile(
                  leading: const Icon(Icons.inventory_2_rounded, color: Colors.blueAccent),
                  title: const Text('Nuevo Producto', style: TextStyle(color: Colors.white, fontSize: 13)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FormScreen(
                          title: 'Nuevo Producto',
                          type: 'PRODUCTO',
                        ),
                      ),
                    ).then((_) => loadData());
                  },
                ),
                const Divider(color: Colors.white10),
                ListTile(
                  leading: const Icon(Icons.grid_view_rounded, color: Colors.purpleAccent),
                  title: const Text('Módulos operativos', style: TextStyle(color: Colors.white, fontSize: 13)),
                  onTap: () {
                    Navigator.pop(context);
                    _openModule('Cobros', 'COBRO');
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final rentabilidad = totalVentas - totalCompras;
    final deuda = totalVentas * 0.3;

    return Scaffold(
      backgroundColor: const Color(0xFF050a14),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '11:08',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: const [
                            Icon(Icons.signal_cellular_4_bar_rounded, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Icon(Icons.wifi_rounded, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Icon(Icons.battery_full_rounded, color: Colors.white, size: 20),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A2B4A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'S',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'SIP Solutions\nERP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0f172a),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: IconButton(
                            onPressed: () => _showQuickActions(context),
                            icon: const Icon(Icons.add, color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF101d34),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white12, width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 12,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'SIP Solutions ERP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF203150),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'DARK UI',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.circle, size: 12, color: Colors.greenAccent),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Cuentas & Alertas Activas',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ),
                              Row(
                                children: [
                                  _smallIconButton(Icons.sync_rounded, Colors.white70),
                                  const SizedBox(width: 8),
                                  _smallIconButton(Icons.add_rounded, Colors.white70),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0c1527),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.red.withOpacity(0.45)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '1 Deuda(s) Vencida(s) • Cobrar \$${deuda.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _openModule('Cobros', 'COBRO'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Text(
                                    'Exportar',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _summaryCard(
                                  title: 'Por Cobrar',
                                  value: '\$${deuda.toStringAsFixed(2)}',
                                  subtitle: '1 Vencidas',
                                  subValue: '(\$3000)',
                                  accent: Colors.redAccent,
                                  icon: Icons.warning_amber_rounded,
                                  background: const Color(0xFF111d2b),
                                  iconBackground: const Color(0x1AFF5A5A),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _summaryCard(
                                  title: 'Ingresos',
                                  value: '\$${totalVentas.toStringAsFixed(0)}',
                                  subtitle: '+12.7% este mes',
                                  subValue: '',
                                  accent: Colors.greenAccent,
                                  icon: Icons.trending_up_rounded,
                                  background: const Color(0xFF101d33),
                                  iconBackground: const Color(0x1A34D399),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _summaryCard(
                                  title: 'Valor Stock',
                                  value: '\$${(totalVentas * 0.45).toStringAsFixed(0)}',
                                  subtitle: 'En inventario activo',
                                  subValue: '',
                                  accent: Colors.blueAccent,
                                  icon: Icons.inventory_2_rounded,
                                  background: const Color(0xFF101d33),
                                  iconBackground: const Color(0x1A60A5FA),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _summaryCard(
                                  title: 'Stock Bajo',
                                  value: '2 Prod.',
                                  subtitle: 'Requieren reposición',
                                  subValue: '',
                                  accent: Colors.orangeAccent,
                                  icon: Icons.warning_amber_rounded,
                                  background: const Color(0xFF101d33),
                                  iconBackground: const Color(0x1AF59E0B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.notifications_rounded, color: Colors.orangeAccent, size: 22),
                                  SizedBox(width: 8),
                                  Text(
                                    'Próximos Vencimientos de\nCobro',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () => _openModule('Cobros', 'COBRO'),
                                child: const Text('Ver Todo', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (items.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'No hay vencimientos programados.',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            )
                          else
                            ...items.take(3).map(
                              (tx) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.02),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${tx.client} • ${tx.paymentMode}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '\$${tx.amount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: tx.amount >= 0 ? Colors.greenAccent : Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0f172a),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Denunciar contenido no seguro',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Icon(Icons.home_rounded, color: Colors.white70, size: 26),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'gemini.google.com',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.add, color: Colors.white, size: 24),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _smallIconButton(IconData icon, Color color) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF203150),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required String subtitle,
    required String subValue,
    required Color accent,
    required IconData icon,
    required Color background,
    required Color iconBackground,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          if (subValue.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subValue,
                style: TextStyle(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
