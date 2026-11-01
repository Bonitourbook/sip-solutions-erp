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
      backgroundColor: const Color(0xFF05080F),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _statusBar(),
                      const SizedBox(height: 12),
                      _header(),
                      const SizedBox(height: 22),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Column(
                            children: [
                              _chartCard(),
                              const SizedBox(height: 16),
                              _actionGrid(),
                              const SizedBox(height: 16),
                              _moduleNav(),
                              const SizedBox(height: 22),
                              _denunciaBar(),
                              const SizedBox(height: 16),
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

  Widget _statusBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '9:37',
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

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF21C6FF), Color(0xFF4F8BFF), Color(0xFFFFB900)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: const Center(
                  child: Icon(Icons.auto_awesome, size: 18, color: Colors.white),
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
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _chartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121E31),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF5A7DAF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rendimiento de Ventas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2A3A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'USD (\$)',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 210,
            child: CustomPaint(
              painter: SalesChartPainter(),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionGrid() {
    return Row(
      children: [
        Expanded(
          child: _actionCard(
            title: 'Nueva\nCta.\nCobrar',
            subtitle: 'Registrar\ncrédito',
            icon: Icons.receipt_long_rounded,
            iconColor: const Color(0xFFff5d5d),
            bgColor: const Color(0xFF1b2333),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FormScreen(
                  title: 'Nueva Cuenta por Cobrar',
                  type: 'COBRO',
                ),
              ),
            ).then((_) => loadData()),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _actionCard(
            title: 'Nueva\nVenta',
            subtitle: 'Contado /\nFactura',
            icon: Icons.shopping_basket_rounded,
            iconColor: const Color(0xFF29d399),
            bgColor: const Color(0xFF1b2333),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FormScreen(
                  title: 'Registrar Venta',
                  type: 'VENTA',
                ),
              ),
            ).then((_) => loadData()),
          ),
        ),
      ],
    );
  }

  Widget _actionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.2,
                      ),
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

  Widget _moduleNav() {
    final modules = [
      _ModuleItem('Inicio', Icons.home_rounded, true),
      _ModuleItem('Cobros', Icons.access_time_rounded, false),
      _ModuleItem('Stock', Icons.inventory_2_rounded, false),
      _ModuleItem('Kardex', Icons.receipt_rounded, false),
      _ModuleItem('Clientes', Icons.people_alt_rounded, false),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF121E31),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: modules
            .map(
              (m) => GestureDetector(
                onTap: () {
                  if (m.label == 'Cobros') {
                    _openModule('Cobros', 'COBRO');
                  } else if (m.label == 'Stock') {
                    _openModule('Stock', 'PRODUCTO');
                  } else if (m.label == 'Kardex') {
                    _openModule('Kardex', 'PRODUCTO');
                  } else if (m.label == 'Clientes') {
                    _openModule('Clientes', null);
                  }
                },
                child: Column(
                  children: [
                    Icon(
                      m.icon,
                      color: m.isSelected ? const Color(0xFF68B7FF) : Colors.white70,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      m.label,
                      style: TextStyle(
                        color: m.isSelected ? const Color(0xFF68B7FF) : Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _denunciaBar() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Denunciar\ncontenido no\nseguro',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: const [
              Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'Probar Gemini Canvas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
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

class _ModuleItem {
  final String label;
  final IconData icon;
  final bool isSelected;

  const _ModuleItem(this.label, this.icon, this.isSelected);
}

class SalesChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5DA9FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    final fillPaint = Paint()
      ..color = const Color(0xFF5DA9FF).withOpacity(0.10)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final axisPaint = Paint()
      ..color = Colors.white.withOpacity(0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final points = [
      const Offset(0, 160),
      const Offset(70, 110),
      const Offset(150, 100),
      const Offset(230, 145),
      const Offset(310, 120),
    ];

    final yLabels = [100000, 140000, 180000, 220000, 260000];
    final xLabels = ['Abr', 'May', 'Jun', 'Oct'];

    final chartLeft = 20.0;
    final chartTop = 10.0;
    final chartRight = size.width - 20;
    final chartBottom = size.height - 30;

    for (int i = 0; i < 5; i++) {
      final y = chartTop + (i * ((chartBottom - chartTop) / 4));
      canvas.drawLine(
        Offset(chartLeft, y),
        Offset(chartRight, y),
        gridPaint,
      );
    }

    canvas.drawLine(
      Offset(chartLeft, 8),
      Offset(chartRight, 8),
      axisPaint,
    );

    final path = Path();
    path.moveTo(points[0].dx + chartLeft, points[0].dy);
    path.lineTo(points[1].dx + chartLeft, points[1].dy - 30);
    path.lineTo(points[2].dx + 50 + chartLeft, points[2].dy - 20);
    path.lineTo(points[3].dx + 50 + chartLeft, points[3].dy - 10);
    path.lineTo(points[4].dx + 30 + chartLeft, points[4].dy - 40);

    final fillPath = Path.from(path);
    fillPath.lineTo(chartRight, chartBottom);
    fillPath.lineTo(chartLeft, chartBottom);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    for (final p in points) {
      final point = Offset(
        p.dx + chartLeft,
        p.dy,
      );
      final circlePaint = Paint()..color = const Color(0xFF0B1F2F);
      final circle = Paint()..color = Colors.white;
      canvas.drawCircle(point, 6, circlePaint);
      canvas.drawCircle(point, 3.2, circlePaint);
      canvas.drawCircle(point, 2.1, circle);
    }

    for (int i = 0; i < yLabels.length; i++) {
      final y = chartTop + (i * ((chartBottom - chartTop) / 4));
      final label = yLabels[i].toString();
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      )..layout();

      final textPainter2 = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: xLabels[i < xLabels.length ? i : xLabels.last],
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      )..layout();

      final x = chartLeft + (i * 72.0);
      final yPos = chartBottom + 10;

      if (i < xLabels.length) {
        textPainter2.layout();
        canvas.drawParagraph(
          textPainter2, Offset(x + 10, yPos),
        );
      }

      canvas.drawParagraph(
        textPainter, Offset(30, y - 18),
      );
    }

    canvas.drawLine(
      Offset(chartLeft, chartTop),
      Offset(chartLeft, chartBottom),
      axisPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
