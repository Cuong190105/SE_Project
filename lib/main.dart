import 'package:eng_dictionary/screens_phone/authentic_phone/login_screen_phone.dart';
import 'package:flutter/material.dart';
import 'database_SQLite/database_helper.dart';
import 'screens_desktop/home_desktop.dart';
import 'screens_phone/home_phone.dart';
import 'authentic/register_screen.dart';
import 'package:window_size/window_size.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'back_end/test_api.dart';
import 'package:eng_dictionary/authentic/splash_screen.dart';
import 'screens_phone/flashcard/flashcard_models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Đảm bảo flashcard mẫu được chèn
  await DatabaseHelper.instance.database; // Khởi tạo DB trước
  await DatabaseHelper.instance.ensureSampleFlashcards();
  // Đồng bộ flashcard khi khởi động
  await FlashcardManager.syncOnStartup();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(1300, 800));
  }
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
        home: LoginScreenPhone(),
      );
    } else {
      return const MaterialApp(
        title: 'EDU dictionary',
        debugShowCheckedModeBanner: false,
        home: LoginScreenPhone(),
        //SplashScreen(),
      );
    }
  }
}