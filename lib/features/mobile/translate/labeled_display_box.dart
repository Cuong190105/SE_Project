import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// Ô hiển thị văn bản dịch
class LabeledDisplayBox extends StatefulWidget {
  final String inputText; // Văn bản cần dịch
  final bool isEditing;

  const LabeledDisplayBox({
    Key? key,
    required this.inputText,
    required this.isEditing,
  }) : super(key: key);

  @override
  _LabeledDisplayBoxState createState() => _LabeledDisplayBoxState();
}

class _LabeledDisplayBoxState extends State<LabeledDisplayBox> {
  String translatedText = ""; // Ban đầu hiển thị thông báo
  Timer? _debounceTimer;

  @override
  void didUpdateWidget(covariant LabeledDisplayBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.inputText != oldWidget.inputText ||
        widget.isEditing != oldWidget.isEditing) {
      if (widget.isEditing) {
        _debounceTranslation(widget.inputText);
      }
    }
  }

  void _debounceTranslation(String text) {
    // Hủy bỏ Timer cũ nếu đang chạy
    _debounceTimer?.cancel();

    // Đặt bộ đếm mới, nếu sau 300ms không có thay đổi mới thì gọi API
    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      _translateText(text);
    });
  }

  // Hàm gọi API để dịch văn bản
  Future<String> translateText(String text, String targetLang) async {
    final url =
        Uri.parse("https://web-production-26d7.up.railway.app/translate");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": text, "target": targetLang}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["translatedText"];
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'dữ liệu khồn được gửi về',
            style: TextStyle(color: Colors.white), // chữ trắng
          ),
          backgroundColor: Colors.red,
        ),
      );
      throw Exception("Lỗi dịch thuật: ${response.body}");
    }
  }

  Future<void> _translateText(String text) async {
    if (text.isEmpty) {
      setState(() => translatedText = ""); // Nếu rỗng, không dịch
      return;
    }
    try {
      final result = await translateText(text, "vi");
      if (mounted) {
        setState(() => translatedText = result); // Cập nhật kết quả
      }
    } catch (e) {
      debugPrint("Lỗi khi dịch: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'không có mạng',
            style: TextStyle(color: Colors.white), // chữ trắng
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode()); // Ẩn bàn phím
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade300, width: 2),
            ),
            padding: const EdgeInsets.all(8),
            alignment: Alignment.topLeft,
            child: SingleChildScrollView(
              child: Text(
                translatedText,
                textAlign: TextAlign.start,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        );
      },
    );
  }
}
