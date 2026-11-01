import 'package:flutter/material.dart';
import '../home_screen.dart';

void main() {
  runApp(const SipSolutionsApp());
}

class SipSolutionsApp extends StatelessWidget {
  const SipSolutionsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIP Solutions ERP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0b0f19),
        primaryColor: const Color(0xFF3b82f6),
      ),
      home: const HomeScreen(),
    );
  }
}
