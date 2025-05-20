import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'search_phone.dart';
import 'home_phone.dart';
import 'translate_phone.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import '../database_SQLite/database_helper.dart';

class VocabularyPhone extends StatefulWidget {
  final Word word;

  const VocabularyPhone({Key? key, required this.word}) : super(key: key);

  @override
  _VocabularyState createState() => _VocabularyState();
}

class _VocabularyState extends State<VocabularyPhone> {
  TextEditingController _controller = TextEditingController();
  Map<String, dynamic> _vocabularyData = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadVocabularyData();
  }

  Future<void> _loadVocabularyData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      _vocabularyData = {
        'word': widget.word.word,
        'partOfSpeech': widget.word.partOfSpeech,
        'usIpa': widget.word.usIpa,
        'ukIpa': widget.word.ukIpa,
        'definition': widget.word.definition,
        'examples': widget.word.examples,
      };
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tải dữ liệu: $e';
        _isLoading = false;
      });
    }
  }

  void _playAudio(String audioUrl) {
    // Placeholder for audio playing logic
  }

  @override
  Widget build(BuildContext context) {
    int streakCount = 5;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
        title: Text(
          'DICTIONARY',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue.shade700),
          onPressed: () {
            Navigator.pop(context);
          },
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchPhone(controller: _controller),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        widget.word.word,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
                    : VocabularyList(word: widget.word),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Wiktionary extends StatefulWidget {
  final Word word;
  const Wiktionary({super.key, required this.word});

  @override
  State<Wiktionary> createState() => _WiktionaryState();
}

class _WiktionaryState extends State<Wiktionary> {
  late Future<List<String>> _results;

  @override
  void initState() {
    super.initState();
    _results = _fetchWord(widget.word.word);
  }

  Future<List<String>> _fetchWord(String word) async {
    final url = 'https://en.wiktionary.org/w/rest.php/v1/page/$word/html';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        dom.Document document = html_parser.parse(response.body);

        List<String> texts = [];

        var pTags = document.getElementsByTagName('p');
        texts.addAll(pTags.map((e) => e.text.trim()));

        var liTags = document.getElementsByTagName('li');
        texts.addAll(liTags.map((e) => e.text.trim()));

        return texts.where((element) => element.isNotEmpty).toList();
      } else {
        throw Exception('Không tìm thấy từ "$word"');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _results,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}', style: TextStyle(color: Colors.red)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có dữ liệu'));
        } else {
          final results = snapshot.data!;
          return Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      results[index],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}

class VocabularyList extends StatefulWidget {
  final Word word;
  VocabularyList({required this.word});

  @override
  _VocabularyListState createState() => _VocabularyListState();
}

class _VocabularyListState extends State<VocabularyList> {
  late Future<Map<String, dynamic>> _wordDetails;

  @override
  void initState() {
    super.initState();
    _wordDetails = _prepareWordDetails(widget.word);
  }

  Future<Map<String, dynamic>> _prepareWordDetails(Word word) async {
    return {
      'type': word.partOfSpeech,
      'phonetic': word.usIpa ?? word.ukIpa ?? 'Không có phiên âm',
      'definition': word.definition,
      'examples': word.examples,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _wordDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('Không tìm thấy dữ liệu'));
        } else {
          final wordType = snapshot.data!;
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${wordType['type']}',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.volume_up, size: 20),
                        SizedBox(width: 5),
                        Text(
                          'US: ${wordType['phonetic']}',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nghĩa: ${wordType['definition']}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (wordType['examples'].isNotEmpty)
                          for (var example in wordType['examples'])
                            Text(
                              '• $example',
                              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                            ),
                        if (wordType['examples'].isEmpty)
                          Text(
                            '• Không có ví dụ',
                            style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                          ),
                      ],
                    ),
                    Divider(),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }
}