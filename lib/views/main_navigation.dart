import 'package:flutter/material.dart';
import 'dashboard_view.dart';
import 'generic_module_view.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardView(),
    const GenericModuleView(moduleTitle: 'Módulo de Cobros y Créditos', filterType: 'COBRO'),
    const GenericModuleView(moduleTitle: 'Módulo de Stock e Inventario', filterType: 'PRODUCTO'),
    const GenericModuleView(moduleTitle: 'Kardex de Movimientos', filterType: null),
    const GenericModuleView(moduleTitle: 'Gestión de Clientes', filterType: 'VENTA'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFF0b0f19),
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Cobros'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Stock'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Kardex'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Clientes'),
          ],
        ),
      ),
    );
  }
}
