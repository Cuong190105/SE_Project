import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:process_run/shell.dart';
import 'dart:async';
import 'search_phone.dart';
import 'home_phone.dart';
import 'translate_phone.dart';
//import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

class VocabularyPhone extends StatefulWidget {
  final String word;

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
  }

  @override
  Widget build(BuildContext context) {
    int streakCount = 5; // Placeholder for streak count

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
              // Word title and search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchPhone(controller: _controller),
                    // Word title
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        widget.word,
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
              
              // Divider
              Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
              
              // Word content
              Expanded(
                child: VocabularyList(word: widget.word),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _playAudio(String audioUrl) {
    // You can use any audio playing package such as just_audio to play the audio
  }

}

// lấy dữ liệu
class Wiktionary extends StatefulWidget {
  final String word;
  const Wiktionary({super.key, required this.word});

  @override
  State<Wiktionary> createState() => _WiktionaryState();
}
class _WiktionaryState extends State<Wiktionary> {
  late Future<List<String>> _results;

  @override
  void initState() {
    super.initState();
    _results = _fetchWord(widget.word);
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
          final results = snapshot.data!; // Lấy dữ liệu từ snapshot
          return Expanded( // Dùng Expanded để bao bọc ListView
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

// danh sách nghĩa
class VocabularyList extends StatefulWidget {
  final String word;
  VocabularyList({required this.word});

  @override
  _VocabularyListState createState() => _VocabularyListState();
}
class _VocabularyListState extends State<VocabularyList> {
  late Future<List<Map<String, dynamic>>> _wordDetails;
  final List<String> _dsTuLoai = [
    'Danh từ', 'Động từ', 'Tính từ', 'Trạng từ',
    'Giới từ', 'Liên từ', 'Thán từ', 'Đại từ', 'Từ hạn định'
  ];

  Future<String> fetchWordDetails(String word) async {
    final url = 'https://vi.wiktionary.org/wiki/$word';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load word details');
    }
  }

  List<Map<String, dynamic>> parseWordDetails(String htmlContent) {
    final document = html_parser.parse(htmlContent);
    final wordDetails = <Map<String, dynamic>>[];

    // Lấy tất cả các phần tử <section> trong document
    final sectionElements0 = document.querySelectorAll('section');
    final filteredSections = sectionElements0.where((section) {
      final h2Element = section.querySelector('h2');
      return h2Element != null && h2Element.text.trim() == 'Tiếng Anh';
    }).toList();

    for (var section in filteredSections) {
      // Lấy tất cả các phần tử <section> con trong section đã lọc
      final sectionElements = section.querySelectorAll('section');
      // Duyệt qua từng section để lấy thông tin
      for (int i = 0; i < sectionElements.length; i++) {
        Map<String, dynamic> wordDetail = {};

        // Lấy tên từ loại (Ví dụ: Danh từ, Động từ, ...)
        final partOfSpeechElement = sectionElements[i].querySelector('.mw-heading h3');
        String partOfSpeech = partOfSpeechElement?.text.trim() ?? 'không rõ từ loại';

        // Kiểm tra nếu từ loại có trong danh sách _dsTuLoai
        if (!_dsTuLoai.contains(partOfSpeech)) {
          continue;  // Nếu không có, bỏ qua phần tử này và tiếp tục vòng lặp
        }

        wordDetail['type'] = partOfSpeech;

        // Lấy phiên âm (nếu có)
        final phoneticElement = sectionElements[i].querySelector('.IPA');
        wordDetail['phonetic'] = phoneticElement?.text.trim() ?? 'không rõ phiên âm';

        // Lấy nghĩa của từ (<li>)
        final meaningElements = sectionElements[i].querySelectorAll('li');
        List<String> meanings = [];
        List<List<String>> examples = [];

        for (var meaningElement in meaningElements) {
          String meaningText = '';
          List<String> examplesText = [];
          final aElements = meaningElement.querySelectorAll('a');
          final ddElements = meaningElement.querySelectorAll('dd');

          for (var aElement in aElements) {
            meaningText += aElement.text.trim();
            meaningText += ", ";
          }

          if (meaningText.isNotEmpty) {
            meaningText = meaningText.substring(0, meaningText.length - 2);
          }

          for (var ddElement in ddElements) {
            examplesText.add(ddElement.text.trim());
          }

          meanings.add(meaningText);
          examples.add(examplesText);
        }

        wordDetail['meaning'] = meanings;
        wordDetail['examples'] = examples;

        // Thêm chi tiết từ vào danh sách
        wordDetails.add(wordDetail);
      }
    }
    return wordDetails;
  }


  @override
  void initState() {
    super.initState();
    _wordDetails = fetchWordDetails(widget.word).then((htmlContent) => parseWordDetails(htmlContent));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _wordDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Không tìm thấy dữ liệu'));
        } else {
          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length, // Sửa lại để đếm đúng số lượng phần tử trong data
            itemBuilder: (context, index) {
              final wordType = data[index]; // Lấy từng phần tử trong data
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Từ loại
                    Text(
                      '${wordType['type']}',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    // Phát âm
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
                    // Nghĩa
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < wordType['meaning'].length; i++)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hiển thị nghĩa với chữ in đậm
                              Text(
                                'Nghĩa: ${wordType['meaning'][i]}',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              // Kiểm tra ví dụ tương ứng với nghĩa này
                              if (wordType['examples'][i].isNotEmpty)
                                for (var example in wordType['examples'][i])
                                  Text(
                                    '• $example',  // Dấu chấm tròn đậm
                                    style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                                  ),
                              // Nếu không có ví dụ, hiển thị dấu chấm tròn đậm với "Không có ví dụ"
                              if (wordType['examples'][i].isEmpty)
                                Text(
                                  '• Không có ví dụ',
                                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                                ),
                            ],
                          ),
                      ],
                    ),
                    Divider(),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
