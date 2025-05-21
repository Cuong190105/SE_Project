import 'package:flutter/material.dart';
import '/features/desktop/my_word/screens/add_word.dart';
import '../../../mobile/my_word/screens/add_word_phone.dart';
import 'package:flutter/foundation.dart';

class AddWordButton extends StatelessWidget {
  const AddWordButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddWordPhone(
                      vocabularyList: [],
                    )),
          );
        } else if (defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.windows) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddWord(
                      vocabularyList: [],
                    )),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade500, // Nền xanh dương
        shape: const CircleBorder(), // Hình tròn
        padding: const EdgeInsets.all(15), // Kích thước nút
        elevation: 1, // Đổ bóng nhẹ
      ),
      child: const Icon(
        Icons.add, // Icon dấu +
        color: Colors.white, // Màu trắng
        size: 32, // Kích thước icon
      ),
    );
  }
}
