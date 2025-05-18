import 'package:flutter/material.dart';
import 'labeled_display_box.dart';
import 'labeled_text_field_box.dart';

class Translate extends StatefulWidget {
  const Translate({super.key});

  @override
  _TranslateState createState() => _TranslateState();
}

class _TranslateState extends State<Translate> {
  TextEditingController textController = TextEditingController();
  TextEditingController _controller = TextEditingController();
  String displayedText = "";
  bool isEditing = true;

  @override
  void initState() {
    super.initState();
    textController.addListener(() {
      setState(() {
        displayedText = "${textController.text}";
      });
    });
  }

  @override
  void dispose() {
    textController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
        title: Text(
          "DỊCH VĂN BẢN",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue.shade700),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tiêu đề ô nhập văn bản
                  Text(
                    "Văn bản gốc",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.35, 
                    constraints: BoxConstraints(minHeight: 180),
                    child: LabeledTextField(
                      controller: textController,
                      isEditing: isEditing,
                      onEditingChanged: (value) {
                        setState(() {
                          isEditing = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tiêu đề ô hiển thị văn bản dịch
                  Text(
                    "Bản dịch",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.35, 
                    constraints: BoxConstraints(minHeight: 180), 
                    child: LabeledDisplayBox(
                      inputText: textController.text,
                      isEditing: isEditing,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
