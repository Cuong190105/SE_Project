import 'dart:io';
import 'package:eng_dictionary/screens_desktop/home_desktop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../screens_mobile/home_mobile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) return const HomeScreenMobile();
    return HomeScreenDesktop();
  }
}
