import 'package:eng_dictionary/screens_phone/authentic_phone/login_screen_phone.dart';
import 'package:flutter/material.dart';
import 'screens_desktop/home_desktop.dart';
import 'screens_phone/home_phone.dart';
import 'authentic/register_screen.dart';
import 'package:window_size/window_size.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'back_end/test_api.dart';  // Import file test API
import 'package:eng_dictionary/authentic/splash_screen.dart';

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
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      return const MaterialApp(
        title: 'EDU dictionary',
        debugShowCheckedModeBanner: false,
        home: SplashScreen(), // Chạy màn hình chính
      );
    } else {
      return const MaterialApp(
        title: 'EDU dictionary',
        debugShowCheckedModeBanner: false,
        home: SplashScreen(), // Chạy màn hình chính
      );
    }
  }
}
//  TestApiScreen(), HomeScreenPhone(), HomeScreenDesktop(),