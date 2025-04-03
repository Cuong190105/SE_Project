import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:process_run/shell.dart';
import 'dart:async';

class Translate extends StatefulWidget {
  const Translate({super.key});

  @override
  _TranslateState createState() => _TranslateState();
}

class _TranslateState extends State<Translate> {
  TextEditingController textController = TextEditingController();
  String displayedText = "";
  Process? _serverProcess;
  @override
  void initState() {
    super.initState();
    _startNodeServer();
    // Lắng nghe sự thay đổi trong ô nhập
    textController.addListener(() {
      setState(() {
        displayedText = "${textController.text}"; // Thêm số 1 vào cuối
      });
    });
  }

  Future<void> _startNodeServer() async {
    var shell = Shell();

    try {
      _serverProcess = await Process.start('node', ['D:/cnpm/SE_Project/node_server/server.js']);
      print("Server Node.js đã chạy!");
    } catch (e) {
      print("Lỗi khi chạy server: $e");
    }
  }

  @override
  void dispose() {
    _stopNodeServer(); // Dừng server khi rời màn hình
    super.dispose();
  }

  void _stopNodeServer() {
    if (_serverProcess != null) {
      _serverProcess!.kill(); // Dừng tiến trình server
      print("Server Node.js đã dừng!");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    int streakCount = 5; // Đợi dữ liệu từ database

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
        leadingWidth: 200,
        leading: Row(
          children: [
            BackButton(color: Colors.blue.shade50),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                'Dịch văn bản',
                softWrap: false,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade50,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Text(
                "$streakCount",
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
            ],
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle),
              child: Icon(Icons.person, color: Colors.blue.shade700, size: 20),
            ),
            onPressed: () {},
          ),
        ],
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
            stops: const [0.3, 1.0],
          ),
        ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'DICTIONARY',
                        softWrap: false,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: screenWidth / 2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(color: Colors.blue.shade100, blurRadius: 5, spreadRadius: 1),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
                              icon: Icon(Icons.search, color: Colors.blue.shade700),
                              onPressed: () {},
                            ),
                            hintText: 'Nhập từ cần tìm kiếm',
                            hintStyle: TextStyle(color: Colors.blue.shade300),
                            border: InputBorder.none,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),

              // 2 Ô nhập và hiển thị văn bản
              ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.67, // Giới hạn chiều cao
            ),
             child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LabeledTextField(title: "Văn bản gốc", controller: textController),
                    LabeledDisplayBox(title: "Bản dịch", inputText: textController.text,),
                  ],
                ),
              ),
          ),
               SizedBox(height: screenHeight*0.1),
            ],
          ),
        ),
      ),
      ),
    );
  }

  // Nút quay lại
  Widget buttonBack(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft, // Canh về góc trái trên
      child: IconButton(
        icon: Icon(Icons.arrow_back, size: 20, color: Colors.black),
        onPressed: () {
          Navigator.pop(context); // Quay lại màn hình trước đó
        },
      ),
    );
  }

}

// Ô nhập văn bản
class LabeledTextField extends StatelessWidget {
  final String title;
  final TextEditingController? controller;

  const LabeledTextField({
    Key? key,
    required this.title,
    this.controller,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề ô nhập văn bản
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Sử dụng LayoutBuilder để tính toán chiều cao còn lại
        Expanded(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: (screenWidth-250) / 2, // Chiều rộng bằng 1/2 màn hình
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade300, width: 2),
              ),
              padding: const EdgeInsets.all(8),
              alignment: Alignment.topLeft, // Căn chữ từ trên xuống

              // Ô nhập văn bản
              child: TextField(
                controller: controller,
                maxLines: null, // Cho phép nhập nhiều dòng
                expands: true,
                textAlign: TextAlign.start, // Căn lề trái
                textAlignVertical: TextAlignVertical.top, // Căn chữ ở trên cùng
                keyboardType: TextInputType.multiline, // Hỗ trợ nhập nhiều dòng
                decoration: const InputDecoration(
                  border: InputBorder.none, // Loại bỏ viền mặc định
                  hintText: "Nhập...",
                  isCollapsed: true, // Chữ bắt đầu từ trên cùng
                ),
              ),
            );
          },
        ),
        ),
      ],
    );
  }
}

// Ô hiển thị văn bản dịch
class LabeledDisplayBox extends StatefulWidget {
  final String title;
  final String inputText; // Văn bản cần dịch

  const LabeledDisplayBox({
    Key? key,
    required this.title,
    required this.inputText,
  }) : super(key: key);

  @override
  _LabeledDisplayBoxState createState() => _LabeledDisplayBoxState();
}

class _LabeledDisplayBoxState extends State<LabeledDisplayBox> {
  String translatedText = "..."; // Ban đầu hiển thị thông báo
  Timer? _debounceTimer;

  @override
  void didUpdateWidget(covariant LabeledDisplayBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.inputText != oldWidget.inputText) {
      _debounceTranslation(widget.inputText);
    }
  }

  void _debounceTranslation(String text) {
    // Hủy bỏ Timer cũ nếu đang chạy
    _debounceTimer?.cancel();

    // Đặt bộ đếm mới, nếu sau 800ms không có thay đổi mới thì gọi API
    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      _translateText(text);
    });
  }

  // Hàm gọi API để dịch văn bản
  Future<String> translateText(String text, String targetLang) async {
    final url = Uri.parse("http://localhost:3000/translate"); // Đổi localhost thành IP nếu chạy trên thiết bị thật
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": text, "target": targetLang}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["translatedText"];
    } else {
      throw Exception("Lỗi dịch thuật: ${response.body}");
    }
  }

  Future<void> _translateText(String text) async {
    if (text.isEmpty) {
      setState(() => translatedText = "..."); // Nếu rỗng, không dịch
      return;
    }
    try {
      final result = await translateText(text, "vi");
      if (mounted) {
        setState(() => translatedText = result); // Cập nhật kết quả
      }
    } catch (e) {
      debugPrint("Lỗi khi dịch: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Ô hiển thị văn bản dịch
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode()); // Ẩn bàn phím
                },
                child: Container(
                  width: (screenWidth - 250) / 2,
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
          ),
        ),
      ],
    );
  }
}

