import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const WarehouseApp()); // ✅ هذا هو الاسم الصحيح
}

class WarehouseApp extends StatelessWidget {
  const WarehouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق المستودع',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal, fontFamily: 'Arial'),
      home: const HomeScreen(),
    );
  }
}
