import 'package:flutter/material.dart';
import 'screens_desktop/home_desktop.dart';
import 'screens_phone/home_phone.dart';
import 'authentic/register_screen.dart';
import 'package:window_size/window_size.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();

  /*if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(1300, 800));// Bạn có thể đặt max size nếu cần: setWindowMaxSize(const Size(1600, 1200));
  }*/

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {

    if (defaultTargetPlatform == TargetPlatform.android
        ||defaultTargetPlatform == TargetPlatform.iOS) {
      return const MaterialApp(
        title: 'EDU dictionary',
        debugShowCheckedModeBanner: false,
        home: HomeScreenPhone(), // Chạy màn hình chính
      );
    } else {
      return const MaterialApp(
        title: 'EDU dictionary',
        debugShowCheckedModeBanner: false,
        home: HomeScreenDesktop(), // Chạy màn hình chính
      );
    }
  }
}
