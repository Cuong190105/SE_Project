import 'dart:convert';
import 'package:eng_dictionary/screens_phone/add_word.dart';
import 'package:eng_dictionary/screens_phone/meaning_list.dart';
import 'package:eng_dictionary/screens_phone/related_word.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'search_phone.dart';
import 'back_button.dart';
class VocabularyPhone extends StatefulWidget {
  final String word;

  const VocabularyPhone({Key? key, required this.word}) : super(key: key);

  @override
  _VocabularyState createState() => _VocabularyState();
}

class _VocabularyState extends State<VocabularyPhone> {
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
    _controller.dispose();
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
        leadingWidth: 300,
        leading: CustomBackButton(color: Colors.white, content: widget.word),
        
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
            child: Column(children: [
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
                                color: selectedIndex == 0
                                    ? Colors.blue
                                    : Colors.grey,
                                fontWeight: selectedIndex == 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth / 10),
                          TextButton(
                            onPressed: () => setState(() => selectedIndex = 1),
                            child: Text(
                              'Các từ ngữ liên quan',
                              style: TextStyle(
                                fontSize: 20,
                                color: selectedIndex == 1
                                    ? Colors.blue
                                    : Colors.grey,
                                fontWeight: selectedIndex == 1
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                      Container(
                        height: screenHeight - 350,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: SearchPhone(controller: _controller),
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
