import 'package:flutter/material.dart';
import 'dashboard_view.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardView(),
    const PlaceholderModule(title: 'Módulo de Cobros'),
    const PlaceholderModule(title: 'Módulo de Stock'),
    const PlaceholderModule(title: 'Módulo de Kardex'),
    const PlaceholderModule(title: 'Módulo de Clientes'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF0b0f19),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Cobros'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Stock'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Kardex'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Clientes'),
        ],
      ),
    );
  }
}

class PlaceholderModule extends StatelessWidget {
  final String title;
  const PlaceholderModule({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: const Color(0xFF111827)),
      body: Center(
        child: Text('$title en desarrollo', style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
