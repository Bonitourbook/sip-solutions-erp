import 'package:flutter/material.dart';
import 'views/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ErpJuanApp());
}

class ErpJuanApp extends StatelessWidget {
  const ErpJuanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ERP Juan v1.0',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0b0f19),
        primaryColor: const Color(0xFF3b82f6),
        cardColor: const Color(0xFF111827),
      ),
      home: const MainNavigation(),
    );
  }
}
