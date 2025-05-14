import 'package:eng_dictionary/features/common/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:eng_dictionary/data/models/database_helper.dart';
import 'package:eng_dictionary/data/models/flashcard_manager.dart';
import 'package:eng_dictionary/data/models/word_manager.dart';
import 'package:window_size/window_size.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Đảm bảo flashcard mẫu được chèn
  await DatabaseHelper.instance.database; // Khởi tạo DB trước
  await DatabaseHelper.instance.ensureSampleFlashcards();
  await DatabaseHelper.instance.ensureSampleWords();
  // Đồng bộ flashcard khi khởi động
  await FlashcardManager.syncOnStartup();
  await WordManager.syncOnStartup();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(1300, 800));
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
   
      return const MaterialApp(
        title: 'EDU dictionary',
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      );
    
  }
}