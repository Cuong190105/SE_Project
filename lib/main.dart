import 'package:flutter/material.dart';
import 'screens/home.dart'; // Import màn hình Home từ thư mục screens
import 'authentic/register_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegisterScreen(), // Chạy màn hình chính
    );
  }
}
