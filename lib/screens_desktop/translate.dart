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
    bool _isHovering = false; // hiệu ứng khi di chuột trở về
    bool isHoveringIcon = false;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
        leadingWidth: screenWidth,
        leading: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
              child: Column(
                children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                 child: Text(
                'DICTIONARY',
                softWrap: false,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                  letterSpacing: 2,
                  ),
                ),
                ),

              StatefulBuilder(
              builder: (context, setState) {

                return MouseRegion(
              onEnter: (_) => setState(() => isHoveringIcon = true),
              onExit: (_) => setState(() => isHoveringIcon = false),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                customBorder: const CircleBorder(), // Để hiệu ứng nhấn bo tròn đúng hình
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: isHoveringIcon ? Colors.grey.shade300 : Colors.white, // Hover đổi màu
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade100,
                        blurRadius: 2,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.book,
                    size: 20,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            );
          },
        ),

          ],
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
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          return MouseRegion(
                            onEnter: (_) => setState(() => _isHovering = true),
                            onExit: (_) => setState(() => _isHovering = false),
                            child: Material(
                              color: _isHovering ? Colors.grey.shade300 : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                borderRadius: BorderRadius.circular(30),
                                splashColor: Colors.blue.withOpacity(0.2),
                                highlightColor: Colors.blue.withOpacity(0.1),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      buttonBack(context),
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


                    ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: screenHeight-160, // Giới hạn chiều cao
                ),
                 child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LabeledTextField(
                          title: "Văn bản gốc",
                          controller: textController,
                          isEditing: isEditing,
                          onEditingChanged: (value) {
                            setState(() {
                              isEditing = value;
                            });
                          },
                        ),
                        SizedBox(width: 15),
                        LabeledDisplayBox(title: "Bản dịch",
                          inputText: textController.text,
                          isEditing: isEditing,),
                      ],
                    ),

                 ),
              ),
                   SizedBox(height: 20),
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
        icon: Icon(Icons.arrow_back, size: 30, color: Colors.blue.shade700),
        onPressed: () {
          Navigator.pop(context); // Quay lại màn hình trước đó
        },

        hoverColor: Colors.grey.shade300.withOpacity(0),              // Màu nền khi di chuột vào
      ),
    );
  }

}

// Ô nhập văn bản
class LabeledTextField extends StatefulWidget {
  final String title;
  final TextEditingController? controller;
  final bool isEditing;
  final ValueChanged<bool> onEditingChanged;

  const LabeledTextField({
    Key? key,
    required this.title,
    this.controller,
    required this.isEditing,
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
        // Tiêu đề ô nhập văn bản
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

        // Ô nhập và nút phía dưới
        Expanded(
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: (screenWidth - 55) / 2,
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
                        hintText: "",
                        isCollapsed: true,
                      ),
                    ),
                  );
                },
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

  const LabeledDisplayBox({
    Key? key,
    required this.title,
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
    if (widget.inputText != oldWidget.inputText || widget.isEditing != oldWidget.isEditing) {
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
                  width: (screenWidth-55) / 2,
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

