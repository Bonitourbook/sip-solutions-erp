import 'package:flutter/material.dart';

import '../controllers/erp_controller.dart';
import 'dashboard_view.dart';
import 'form_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key, required this.controller});

  final ErpController controller;

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      DashboardView(controller: widget.controller),
      FormScreen(controller: widget.controller),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Transacción',
          ),
        ],
      ),
    );
  }
}
