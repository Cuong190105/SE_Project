import 'package:flutter/material.dart';
import 'package:eng_dictionary/features/common/widgets/streak_count.dart';
import 'package:eng_dictionary/features/desktop/settings/widgets/setting_button.dart';
import 'package:eng_dictionary/features/common/widgets/translate/labeled_text_field_box.dart';
import 'package:eng_dictionary/features/common/widgets/translate/labeled_display_box.dart';
import 'package:eng_dictionary/features/common/widgets/search.dart';
import 'package:eng_dictionary/features/common/widgets/logo_small.dart';
import 'package:eng_dictionary/features/common/widgets/back_button.dart';
import 'package:googleapis/admob/v1.dart';

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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final boxHeight = (screenHeight - 300) / 2;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
        title: Text(
          "DỊCH VĂN BẢN",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
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
                  const SizedBox(height: 20),
                  Container(
                    width: screenWidth,
                    height: boxHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: LabeledTextField(
                      title: "Văn bản gốc",
                      controller: textController,
                      isEditing: isEditing,
                      onEditingChanged: (value) {
                        setState(() {
                          isEditing = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: screenWidth,
                    height: boxHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: LabeledDisplayBox(
                      title: "Bản dịch",
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
