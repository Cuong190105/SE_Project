import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:eng_dictionary/data/models/database_helper.dart';
import 'package:eng_dictionary/features/mobile/vocabulary/vocabulary_detail.dart';
import 'dart:async';

class SearchPhone extends StatefulWidget {
  final TextEditingController controller;

  const SearchPhone({Key? key, required this.controller}) : super(key: key);

  @override
  _SearchPhoneState createState() => _SearchPhoneState();
}

class _SearchPhoneState extends State<SearchPhone> {
  Future<List<String>>? _suggestions;
  Set<int> _hoveredIndexes = {};
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _searchWords(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _suggestions = query.isEmpty ? null : fetchSuggestions(query);
        });
      }
    });
  }

  Future<List<String>> fetchSuggestions(String query) async {
    try {
      final url = 'https://api.datamuse.com/sug?s=$query';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

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
    } catch (e) {
      debugPrint('Lỗi lấy gợi ý: $e');
      rethrow;
    }
  }

  Future<Word> _getOrCreateWord(String wordText) async {
    final dbHelper = DatabaseHelper.instance;
    final words = await dbHelper.getWords();
    final existingWord = words.firstWhere(
          (w) => w.word.toLowerCase() == wordText.toLowerCase(),
      orElse: () {
        final newWord = Word(
          wordId: const Uuid().v4(),
          userEmail: 'unknown_user@example.com',
          word: wordText,
          partOfSpeech: 'Unknown',
          definition: 'No definition available',
          examples: [],
          synonyms: [],
          antonyms: [],
          family: [],
          phrases: [],
          media: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: false,
          isDeleted: false,
        );
        dbHelper.insertWord(newWord);
        return newWord;
      },
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
            onChanged: _searchWords,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                icon: Icon(Icons.clear, color: Colors.blue.shade700),
                onPressed: () {
                  widget.controller.clear();
                  _searchWords('');
                },
              )
                  : null,
              hintText: 'Nhập từ cần tìm kiếm',
              hintStyle: TextStyle(color: Colors.blue.shade300),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
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
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'Không thể tải gợi ý: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final data = snapshot.data!;
                  return Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 300),
                    color: Colors.white,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final wordText = data[index];
                        final isHovered = _hoveredIndexes.contains(index);

                        return MouseRegion(
                          onEnter: (_) => setState(() => _hoveredIndexes.add(index)),
                          onExit: (_) => setState(() => _hoveredIndexes.remove(index)),
                          child: Container(
                            color: isHovered ? Colors.grey.shade200 : Colors.transparent,
                            child: ListTile(
                              title: Text(
                                wordText,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16),
                              ),
                              dense: true,
                              onTap: () {
                                widget.controller.clear();
                                _searchWords('');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VocabularyPhone(word: wordText),
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
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: const Center(
                      child: Text(
                        'Không tìm thấy gợi ý.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}