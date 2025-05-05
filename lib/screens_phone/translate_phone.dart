import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:process_run/shell.dart';
import 'dart:async';

class TranslatePhone extends StatefulWidget {
  const TranslatePhone({super.key});

  @override
  _TranslateState createState() => _TranslateState();
}

class _TranslateState extends State<TranslatePhone> {
  TextEditingController textController = TextEditingController();
  String displayedText = "";
  Process? _serverProcess;
  bool isEditing = true; // chuyển chế độ
  @override
  void initState() {
    super.initState();
    _startNodeServer();
    // Lắng nghe sự thay đổi trong ô nhập
    textController.addListener(() {
      setState(() {
        displayedText = "${textController.text}";
      });
    });
  }

  Future<void> _startNodeServer() async {
    var shell = Shell();

    try {
      //_serverProcess = await Process.start('node', ['D:/cnpm/SE_Project/node_server/server.js']);
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
    int streakCount = 5; // Đợi dữ liệu từ database
    bool _isHovering = false; // hiệu ứng khi di chuột trở về
    bool isHoveringIcon = false;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue.shade300,
          elevation: 0,
          title: const Text(
            'DICTIONARY',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                wordSpacing: 2),
          ),
          leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
          actions: [
            Container(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$streakCount',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                    Icon(
                      Icons.local_fire_department,
                      size: 28,
                      color: Colors.orange.shade600,
                    ),
                  ],
                ),
              ),
            )
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
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return MouseRegion(
                          child: Material(
                            color: _isHovering
                                ? Colors.grey.shade300
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                            child: InkWell(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(width: 8),
                                    Text(
                                      'Dịch văn bản',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 2 Ô nhập và hiển thị văn bản
                Expanded(
                  child: LayoutBuilder(builder: (context, constraints) {
                    double availableHeight =
                        constraints.maxHeight; // Lấy chiều cao còn lại
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LabeledTextField(
                          title: "Văn bản gốc",
                          controller: textController,
                          isEditing: isEditing,
                          height: availableHeight / 2 - 5,
                          onEditingChanged: (value) {
                            setState(() {
                              isEditing = value;
                            });
                          },
                        ),
                        SizedBox(height: 10),
                        LabeledDisplayBox(
                          title: "Bản dịch",
                          inputText: textController.text,
                          isEditing: isEditing,
                          height: availableHeight / 2 - 5,
                        ),
                      ],
                    );
                  }),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ));
  }
}

// Ô nhập văn bản
class LabeledTextField extends StatefulWidget {
  final String title;
  final TextEditingController? controller;
  final bool isEditing;
  final double height;
  final ValueChanged<bool> onEditingChanged;

  const LabeledTextField({
    Key? key,
    required this.title,
    this.controller,
    required this.isEditing,
    required this.height,
    required this.onEditingChanged,
  }) : super(key: key);

  @override
  State<LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<LabeledTextField> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ô nhập và nút phía dưới
        Stack(
          children: [
            Container(
              width: screenWidth - 20,
              height: widget.height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade300, width: 2),
              ),
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 48),
              alignment: Alignment.topLeft,
              child: TextField(
                controller: widget.controller,
                maxLines: null,
                expands: true,
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.top,
                keyboardType: TextInputType.multiline,
                //readOnly: !isEditing, // Chế độ chỉnh sửa hay không
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Nhập văn bản",
                  isCollapsed: true,
                ),
              ),
            ),
            // Nút đặt dưới cùng bên trái của ô
            Positioned(
              bottom: 8,
              left: 8,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.translate),
                    tooltip: 'Dịch trực tiếp',
                    color: widget.isEditing ? Colors.blue : Colors.grey,
                    onPressed: () {
                      setState(() {
                        widget.onEditingChanged(true);
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    tooltip: 'Chỉnh sửa',
                    color: !widget.isEditing ? Colors.blue : Colors.grey,
                    onPressed: () {
                      setState(() {
                        widget.onEditingChanged(false);
                      });
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}

// Ô hiển thị văn bản dịch
class LabeledDisplayBox extends StatefulWidget {
  final String title;
  final String inputText; // Văn bản cần dịch
  final bool isEditing;
  final double height;

  const LabeledDisplayBox({
    Key? key,
    required this.title,
    required this.inputText,
    required this.isEditing,
    required this.height,
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
    final url = Uri.parse(
        "https://my-translation-api.vercel.app/api/translate"); // Đổi localhost thành IP nếu chạy trên thiết bị thật
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
            'Lỗi mạng',
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
            'Không thể dịch',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ô hiển thị văn bản dịch
        GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode()); // Ẩn bàn phím
          },
          child: Container(
            width: screenWidth - 20,
            height: widget.height,
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
        ),
      ],
    );
  }
}
