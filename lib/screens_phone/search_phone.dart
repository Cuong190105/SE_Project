import 'package:flutter/material.dart';
import 'translate_phone.dart';
import 'vocabularies.dart';
import 'vocabulary_phone.dart';
import 'package:eng_dictionary/screens_desktop/authentic_desktop/register_screen.dart';
import 'settings_phone.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../database_SQLite/database_helper.dart';

class SearchPhone extends StatefulWidget {
  final TextEditingController controller;

  SearchPhone({Key? key, required this.controller}) : super(key: key);

  @override
  _Search createState() => _Search();
}

class _Search extends State<SearchPhone> {
  Future<List<String>>? _suggestions;
  Set<int> _hoveredIndexes = {};
  bool _mounted = true;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  void _searchWords(String query) {
    if (_mounted) {
      setState(() {
        _suggestions = fetchSuggestions(query);
      });
    }
  }

  Future<List<String>> fetchSuggestions(String query) async {
    final url = 'https://api.datamuse.com/sug?s=$query';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is List) {
        return decoded
            .where((item) => item != null && item['word'] != null)
            .map<String>((item) => item['word'] as String)
            .take(10)
            .toList();
      } else {
        throw Exception('Định dạng phản hồi API không hợp lệ');
      }
    } else {
      throw Exception('Không thể lấy được gợi ý');
    }
  }

  // Tìm từ trong cơ sở dữ liệu hoặc tạo mới nếu không tìm thấy
  Future<Word> _getOrCreateWord(String wordText) async {
    final dbHelper = DatabaseHelper.instance;
    final words = await dbHelper.getWords();
    final existingWord = words.firstWhere(
          (w) => w.word.toLowerCase() == wordText.toLowerCase(),
      orElse: () => Word(
        wordId: wordText, // Tạm thời dùng wordText làm ID
        userEmail: 'unknown_user@example.com',
        word: wordText,
        partOfSpeech: 'Unknown',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return existingWord;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100,
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.controller,
            onChanged: (value) {
              _searchWords(value);
              setState(() {});
            },
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: Colors.blue.shade700),
                onPressed: () {
                  widget.controller.clear();
                  _searchWords('');
                  setState(() {});
                },
              ),
              hintText: 'Nhập từ cần tìm kiếm',
              hintStyle: TextStyle(color: Colors.blue.shade300),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 15),
            ),
            textAlign: TextAlign.start,
          ),
          Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
          if (widget.controller.text.isNotEmpty)
            FutureBuilder<List<String>>(
              future: _suggestions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    color: Colors.white,
                    child: Center(
                      child: Text('${snapshot.error}',
                          style: TextStyle(color: Colors.red)),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final data = snapshot.data!;
                  return Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxHeight: 300,
                    ),
                    color: Colors.white,
                    child: data.isEmpty
                        ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text('Không tìm thấy định nghĩa.',
                            style: TextStyle(color: Colors.red)),
                      ),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final wordText = data[index];
                        final isHovered = _hoveredIndexes.contains(index);

                        return MouseRegion(
                          onEnter: (_) {
                            if (_mounted) {
                              setState(() {
                                _hoveredIndexes.add(index);
                              });
                            }
                          },
                          onExit: (_) {
                            if (_mounted) {
                              setState(() {
                                _hoveredIndexes.remove(index);
                              });
                            }
                          },
                          child: Container(
                            color: isHovered
                                ? Colors.grey.shade300
                                : Colors.transparent,
                            child: ListTile(
                              title: Text(
                                wordText,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 14),
                              ),
                              dense: true,
                              onTap: () async {
                                if (_mounted) {
                                  widget.controller.clear();
                                  _searchWords('');
                                }
                                // Tìm hoặc tạo đối tượng Word
                                final word = await _getOrCreateWord(wordText);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VocabularyPhone(
                                      word: word,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return SizedBox();
                }
              },
            ),
        ],
      ),
    );
  }
}