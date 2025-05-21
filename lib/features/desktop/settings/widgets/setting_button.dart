import 'package:flutter/material.dart';
import 'package:eng_dictionary/features/desktop/settings/setting_screen.dart';
import 'package:eng_dictionary/features/mobile/settings/screens/setting_screen.dart';
class SettingButton extends StatelessWidget {
  const SettingButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
   return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle),
        child: Icon(Icons.person, color: Colors.blue.shade700, size: 20),
      ),
      onPressed: () {
        Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Settings(userEmail: 'udfhdyfg@gmail.com',)),
              );
      },
    );
  }
}