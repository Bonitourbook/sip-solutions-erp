import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import 'inventory_screen.dart';
import 'sales_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int totalProducts = 0;
  int lowStockCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    final products = await DatabaseHelper.instance.getProducts();
    setState(() {
      totalProducts = products.length;
      lowStockCount = products.where((p) => p.stock <= p.minStock).length;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0b0f19),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF151c2c),
        title: Row(
          children: [
            Icon(Icons.business_center, color: Color(0xFF3b82f6), size: 24),
            SizedBox(width: 10),
            Text(
              'SIP Solutions ERP',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white70),
            onPressed: () {
              setState(() => isLoading = true);
              _loadMetrics();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF3b82f6)))
          : RefreshIndicator(
              onRefresh: _loadMetrics,
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  Text(
                    'DASHBOARD OVERVIEW',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 1.1),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          title: 'Productos',
                          value: '$totalProducts',
                          subtitle: 'En catálogo',
                          icon: Icons.inventory_2_outlined,
                          accentColor: Color(0xFF3b82f6),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildKpiCard(
                          title: 'Stock Bajo',
                          value: '$lowStockCount',
                          subtitle: 'Requieren reposición',
                          icon: Icons.warning_amber_rounded,
                          accentColor: lowStockCount > 0 ? Colors.redAccent : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'MÓDULOS DE GESTIÓN',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 1.1),
                  ),
                  SizedBox(height: 12),
                  _buildMenuButton(
                    context,
                    title: 'Gestión de Inventario y Stock',
                    subtitle: 'Ver, editar, crear y eliminar productos',
                    icon: Icons.grid_view_rounded,
                    color: Color(0xFF3b82f6),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => InventoryScreen()))
                          .then((_) => _loadMetrics());
                    },
                  ),
                  SizedBox(height: 12),
                  _buildMenuButton(
                    context,
                    title: 'Ventas y Colaboradores',
                    subtitle: 'Registrar ventas con tarifas diferenciadas',
                    icon: Icons.point_of_sale_rounded,
                    color: Colors.greenAccent,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SalesScreen()))
                          .then((_) => _loadMetrics());
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF151c2c),
        borderRadius: BorderRadius.circular(12),
        border: Border(top: BorderSide(color: accentColor, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.white60, fontWeight: FontWeight.w600)),
              Icon(icon, color: accentColor, size: 18),
            ],
          ),
          SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Color(0xFF151c2c),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                    SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.white54)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }
}
