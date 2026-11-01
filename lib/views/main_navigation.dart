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

  late final List<Widget> _screens = [
    const DashboardView(),
    const GenericModuleView(
      moduleTitle: 'ERP Juan - Cobros',
      filterType: 'VENTA',
    ),
    const GenericModuleView(
      moduleTitle: 'ERP Juan - Stock',
      filterType: 'COMPRA',
    ),
    const GenericModuleView(
      moduleTitle: 'ERP Juan - Kardex',
      filterType: 'VENTA',
    ),
    const GenericModuleView(
      moduleTitle: 'ERP Juan - Clientes',
      filterType: 'VENTA',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;

        return Scaffold(
          backgroundColor: const Color(0xFF05080F),
          body: SafeArea(child: _screens[_currentIndex]),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0b0f19),
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: const Color(0xFF68B7FF),
              unselectedItemColor: Colors.white60,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: isCompact ? 10 : 12,
              unselectedFontSize: isCompact ? 10 : 12,
              iconSize: isCompact ? 22 : 26,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.schedule_rounded),
                  label: 'Cobros',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_outlined),
                  label: 'Stock',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_rounded),
                  label: 'Kardex',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline_rounded),
                  label: 'Clientes',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
