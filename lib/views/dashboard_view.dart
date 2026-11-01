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
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 26),
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2738),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'MENÚ RÁPIDO ERP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 18),
                _quickActionTile(
                  icon: Icons.receipt_long_rounded,
                  iconColor: Colors.redAccent,
                  label: 'Nueva Cuenta por Cobrar',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FormScreen(
                          title: 'Nueva Cuenta por Cobrar',
                          type: 'VENTA',
                        ),
                      ),
                    ).then((_) => loadData());
                  },
                ),
                const SizedBox(height: 12),
                _quickActionTile(
                  icon: Icons.shopping_cart_rounded,
                  iconColor: Colors.greenAccent,
                  label: 'Registrar Venta',
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
                const SizedBox(height: 12),
                _quickActionTile(
                  icon: Icons.inventory_2_rounded,
                  iconColor: Colors.blueAccent,
                  label: 'Nuevo Producto',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FormScreen(
                          title: 'Nuevo Producto',
                          type: 'COMPRA',
                        ),
                      ),
                    ).then((_) => loadData());
                  },
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _quickActionTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF1F2A3B),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deuda = totalVentas * 0.3;
    final rentabilidad = totalVentas - totalCompras;

    return Scaffold(
      backgroundColor: const Color(0xFF05080F),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      _topBar(),
                      const SizedBox(height: 18),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _headerGemini(),
                              const SizedBox(height: 20),
                              _alertBanner(
                                text: '1 Deuda(s) Vencida(s) • Cobrar \$${deuda.toStringAsFixed(0)}',
                                accent: Colors.redAccent,
                                showAction: true,
                                actionLabel: 'Exportar',
                                onActionTap: () => _openModule('Cobros', 'COBRO'),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _metricCard(
                                      title: 'Por Cobrar',
                                      value: '\$${deuda.toStringAsFixed(2)}',
                                      subtitle: '1 Vencidas',
                                      subValue: '(\$3000)',
                                      accent: Colors.redAccent,
                                      icon: Icons.warning_amber_rounded,
                                      iconColor: Colors.redAccent,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _metricCard(
                                      title: 'Ingresos',
                                      value: '\$${totalVentas.toStringAsFixed(0)}',
                                      subtitle: '+12.7% este mes',
                                      accent: Colors.greenAccent,
                                      icon: Icons.trending_up_rounded,
                                      iconColor: Colors.greenAccent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _metricCard(
                                      title: 'Valor Stock',
                                      value: '\$${(totalVentas * 0.45).toStringAsFixed(0)}',
                                      subtitle: 'En inventario activo',
                                      accent: Colors.blueAccent,
                                      icon: Icons.inventory_2_rounded,
                                      iconColor: Colors.blueAccent,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _metricCard(
                                      title: 'Stock Bajo',
                                      value: '2 Prod.',
                                      subtitle: 'Requieren reposición',
                                      accent: Colors.orangeAccent,
                                      icon: Icons.warning_amber_rounded,
                                      iconColor: Colors.orangeAccent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _sectionTitle(),
                              const SizedBox(height: 10),
                              if (items.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF111827),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: const Text(
                                    'No hay registros para mostrar.',
                                    style: TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                )
                              else
                                ...items.take(3).map(
                                  (tx) => Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF111827),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.white10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${tx.client} • ${tx.paymentMode}',
                                            overflow: TextOverflow.ellipsis,
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
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              _bottomActionRow(),
                              const SizedBox(height: 20),
                              _browserBar(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '11:07',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Row(
            children: const [
              Icon(Icons.signal_cellular_4_bar_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Icon(Icons.wifi_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Icon(Icons.battery_full_rounded, color: Colors.white, size: 22),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerGemini() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2AD7FF), Color(0xFF4C8DFF), Color(0xFFFFC857)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: const Center(
                child: Icon(Icons.auto_awesome, color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Gemini',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _showQuickActions(context),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _alertBanner({
    required String text,
    required Color accent,
    required bool showAction,
    required String actionLabel,
    required VoidCallback onActionTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF101d34),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.warning_amber_rounded, color: accent, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (showAction)
            TextButton(
              onPressed: onActionTap,
              child: Text(
                actionLabel,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required String subtitle,
    String? subValue,
    required Color accent,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
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
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 28,
              fontWeight: FontWeight.w700,
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
          if (subValue != null && subValue.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subValue,
                style: TextStyle(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.notifications_rounded, color: Colors.orangeAccent, size: 20),
            SizedBox(width: 8),
            Text(
              'Próximos Vencimientos de\nCobro',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                height: 1.15,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () => _openModule('Cobros', 'COBRO'),
          child: const Text('Ver Todo', style: TextStyle(color: Colors.white70, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _bottomActionRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF121E31),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navIcon(label: 'Inicio', icon: Icons.home_rounded, active: true),
          _navIcon(label: 'Cobros', icon: Icons.schedule_rounded, active: false),
          _navIcon(label: 'Stock', icon: Icons.inventory_2_rounded, active: false),
          _navIcon(label: 'Kardex', icon: Icons.receipt_long_rounded, active: false),
          _navIcon(label: 'Clientes', icon: Icons.people_alt_rounded, active: false),
        ],
      ),
    );
  }

  Widget _navIcon({
    required String label,
    required IconData icon,
    required bool active,
  }) {
    return GestureDetector(
      onTap: () {
        if (label == 'Cobros') {
          _openModule('Cobros', 'COBRO');
        } else if (label == 'Stock') {
          _openModule('Stock', 'PRODUCTO');
        } else if (label == 'Kardex') {
          _openModule('Kardex', 'PRODUCTO');
        } else if (label == 'Clientes') {
          _openModule('Clientes', null);
        }
      },
      child: Column(
        children: [
          Icon(icon, color: active ? const Color(0xFF68B7FF) : Colors.white70, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFF68B7FF) : Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _browserBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          const Icon(Icons.home_filled, color: Colors.white, size: 26),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'gemini.google.com',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF1f2a38),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 10),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF1f2a38),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '12',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.more_vert_rounded, color: Colors.white, size: 24),
        ],
      ),
    );
  }
}
