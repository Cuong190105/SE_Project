import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'authentic/register_screen.dart';
import 'package:window_size/window_size.dart';
import 'dart:io';

void main() {

  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(1300, 800));
    // Bạn có thể đặt max size nếu cần: setWindowMaxSize(const Size(1600, 1200));
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(), // Chạy màn hình chính
    );
  }
}
