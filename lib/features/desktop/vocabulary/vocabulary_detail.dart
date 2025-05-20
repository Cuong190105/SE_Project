import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:process_run/shell.dart';
import 'dart:async';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:file_selector/file_selector.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:eng_dictionary/features/common/widgets/vocabulary/meaning_list.dart';
import 'package:eng_dictionary/features/common/widgets/vocabulary/related_words_list.dart';
import 'package:eng_dictionary/features/common/widgets/streak_count.dart';
import 'package:eng_dictionary/features/mobile/settings/widgets/setting_button.dart';
import 'package:eng_dictionary/features/common/widgets/translate/labeled_text_field_box.dart';
import 'package:eng_dictionary/features/common/widgets/streak_count.dart';
import 'package:eng_dictionary/features/common/widgets/search.dart';
import 'package:eng_dictionary/features/common/widgets/logo_small.dart';
import 'package:eng_dictionary/features/common/widgets/back_button.dart';
class Vocabulary extends StatefulWidget {
  final String word;

  const Vocabulary({Key? key, required this.word}) : super(key: key);

  @override
  _VocabularyState createState() => _VocabularyState();
}

class _VocabularyState extends State<Vocabulary> {
  TextEditingController _controller = TextEditingController();
  int selectedIndex = 0;
  late final MeaningList _vocabularyList;
  late final RelatedWordsList _relatedWordsList;

  @override
  void initState() {
    super.initState();
    _vocabularyList = MeaningList(word: widget.word);
    _relatedWordsList = RelatedWordsList(word: widget.word);
  }

  void dispose() {
    _vocabularyList == null;
    _relatedWordsList == null;
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
                          const SizedBox(height: 100),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () => setState(() => selectedIndex = 0),
                                child: Text(
                                  'Ý nghĩa',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: selectedIndex == 0 ? Colors.blue : Colors.grey,
                                    fontWeight: selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
                                  ),

                                ),
                              ),
                              SizedBox(width: screenWidth/5),
                              TextButton(
                                onPressed: () => setState(() => selectedIndex = 1),
                                child: Text(
                                  'Các từ ngữ liên quan',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: selectedIndex == 1 ? Colors.blue : Colors.grey,
                                    fontWeight: selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 50),
                          Container(
                            height: screenHeight - 240,
                            child: IndexedStack(
                              index: selectedIndex,
                              children: [
                                _vocabularyList,
                                _relatedWordsList,
                              ],
                            ),
                          ),
                        ],
                      ),

                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          child: Search(controller: _controller),
                        ),
                      ),

                      CustomBackButton(content: widget.word),

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