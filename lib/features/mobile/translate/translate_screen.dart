import 'package:flutter/material.dart';
import 'dart:io';
import 'package:eng_dictionary/features/common/widgets/streak_count.dart';
import 'package:eng_dictionary/features/desktop/settings/widgets/setting_button.dart';
import 'package:eng_dictionary/features/common/widgets/translate/labeled_text_field_box.dart';
import 'package:eng_dictionary/features/common/widgets/translate/labeled_display_box.dart';
import 'package:eng_dictionary/features/common/widgets/search.dart';
import 'package:eng_dictionary/features/common/widgets/logo_small.dart';
import 'package:eng_dictionary/features/common/widgets/back_button.dart';
class Translate extends StatefulWidget {
  const Translate({super.key});

  @override
  _TranslateState createState() => _TranslateState();
}

class _TranslateState extends State<Translate> {
  TextEditingController textController = TextEditingController();
  TextEditingController _controller = TextEditingController();
  String displayedText = "";
  bool isEditing = true; // chuyển chế độ
  
  @override
  void initState() {
    super.initState();
    // Lắng nghe sự thay đổi trong ô nhập
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    int streakCount = 5; // Đợi dữ liệu từ database
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
        leadingWidth: screenWidth,
        leading: Stack(
          children: [
            LogoSmall(),
          ],
        ),
        actions: [
          StreakCount(),
          SettingButton(),
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
                  Stack(
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 80),

                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: screenHeight - 160,
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
                                  LabeledDisplayBox(
                                    title: "Bản dịch",
                                    inputText: textController.text,
                                    isEditing: isEditing,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),

                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          child: Search(controller: _controller),
                        ),
                      ),

                      CustomBackButton(content: 'Dịch văn bản'),

                    ],
                  ),
                ]
            ),
          ),
        ),
      ),
    );
  }
}
