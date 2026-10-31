import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(SipSolutionsApp());
}

class SipSolutionsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIP Solutions ERP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF0b0f19),
        primaryColor: Color(0xFF3b82f6),
      ),
      home: HomeScreen(),
    );
  }
}
