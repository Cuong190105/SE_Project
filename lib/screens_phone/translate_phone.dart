import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class TranslatePhone extends StatefulWidget {
  const TranslatePhone({super.key});

  @override
  _TranslateState createState() => _TranslateState();
}

class _TranslateState extends State<TranslatePhone> {
  TextEditingController textController = TextEditingController();
  String displayedText = "";
  bool isEditing = true;

  @override
  void initState() {
    super.initState();
    textController.addListener(() {
      setState(() {
        displayedText = textController.text;
      });
    });
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int streakCount = 5;
    bool isHovering = false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
        title: const Text(
          'DICTIONARY',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            wordSpacing: 2,
          ),
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
                      color: Colors.white,
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
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return MouseRegion(
                        onEnter: (_) => setState(() => isHovering = true),
                        onExit: (_) => setState(() => isHovering = false),
                        child: Material(
                          color: isHovering ? Colors.grey.shade300 : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                          child: InkWell(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  double availableHeight = constraints.maxHeight;
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
      ),
    );
  }
}

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
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Nhập văn bản",
                  isCollapsed: true,
                ),
              ),
            ),
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
            ),
          ],
        ),
      ],
    );
  }
}

class LabeledDisplayBox extends StatefulWidget {
  final String title;
  final String inputText;
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
  String translatedText = "";
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
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      _translateText(text);
    });
  }

  Future<String> translateText(String text, String targetLang) async {
    final url = Uri.parse("https://my-translation-api.vercel.app/api/translate");
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
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      throw Exception("Lỗi dịch thuật: ${response.body}");
    }
  }

  Future<void> _translateText(String text) async {
    if (text.isEmpty) {
      setState(() => translatedText = "");
      return;
    }
    try {
      final result = await translateText(text, "vi");
      if (mounted) {
        setState(() => translatedText = result);
      }
    } catch (e) {
      debugPrint("Lỗi khi dịch: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể dịch',
            style: TextStyle(color: Colors.white),
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
        GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
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