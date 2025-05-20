import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:html/parser.dart' as html_parser;

class RelatedWordsList extends StatefulWidget {
  final String word;
  RelatedWordsList({required this.word});

  @override
  _RelatedWordsListState createState() => _RelatedWordsListState();
}
class _RelatedWordsListState extends State<RelatedWordsList> {
  bool isLoading = true;

  Map<String, String> prefixes = {
    "un": "",
    "dis": "",
    "re": "",
    "im": "",
    "in": "",
    "il": "",
    "ir": "",
    "pre": "",
    "over": "",
    "mis": "",
    "multi": "",
  };

  Map<String, String> suffixes = {
    "ness": "",
    "ly": "",
    "ing": "",
    "ful": "",
    "less": "",
    "er": "",
    "or": "",
    "ist": "",
    "ship": "",
    "dom": "",
    "ism": "",
    "al": "",
    "ity": "",
    "ment": "",
    "ion": "",
    "ance": "",
    "ence": "",
    "ant": "",
    "en": "",
    "fly": "",
    "ize": "",
    "ise": "",
    "ive": "",
    "able": "",
    "ible": "",
    "ous": "",
    "ic": "",
  };

  Map<String, List<String>> relatedWords = {
    "synonyms": [],
    "antonyms": [],
    "wordFamily": [],
    "phrases": [],
  };

  @override
  void initState() {
    super.initState();
    fetchRelatedWords(widget.word);
  }

  Future<List<String>> fetchIdioms(String word) async {

    List<String> _idoims = [];
    final phrasesUrl = 'https://idioms.thefreedictionary.com/$word';
    final response = await http.get(Uri.parse(phrasesUrl));

    if (response.statusCode == 200) {
      final document = html_parser.parse(response.body);

      final section = document
          .querySelectorAll('section')
          .where((section) => section.attributes.isEmpty)
          .toList();
      final idioms = section[0].querySelectorAll('li');
      for (final idiom in idioms) {
          _idoims.add(idiom.text.trim());
      }
    } else {
      print('Failed to load data. Status code: ${response.statusCode}');
    }
    return _idoims;
  }

  Future<void> fetchRelatedWords(String word) async {
    setState(() {
      isLoading = true;
    });

    try {
      final synonymUrl = 'https://api.datamuse.com/words?rel_syn=$word';
      final antonymUrl = 'https://api.datamuse.com/words?rel_ant=$word';
      final familyUrl1 = 'https://api.datamuse.com/words?ml=$word';
      final familyUrl2 = 'https://api.datamuse.com/words?rel_trg=$word';

      final responses = await Future.wait([
        http.get(Uri.parse(synonymUrl)),
        http.get(Uri.parse(antonymUrl)),
        http.get(Uri.parse(familyUrl1)),
        http.get(Uri.parse(familyUrl2)),
      ]);

      if (responses.every((res) => res.statusCode == 200)) {
        final synonymData = json.decode(responses[0].body) as List;
        final antonymData = json.decode(responses[1].body) as List;
        final familyData1 = json.decode(responses[2].body) as List;
        final familyData2 = json.decode(responses[3].body) as List;

        // Lọc từ liên quan có phần gốc tương tự (dựa trên tiền tố/suffix đơn giản)
        final wordI = word.endsWith('y') ? word.substring(0, word.length - 1) + 'i' : word;

        final allFamilyCandidates = [
          ...familyData1.map((item) => item['word'] as String),
          ...familyData2.map((item) => item['word'] as String),
        ];

        final familyWords = allFamilyCandidates
            .where((w) {
          final wI = w.endsWith('y') ? w.substring(0, w.length - 1) + 'i' : w;
          if (w == word) return false;

          return !w.contains(' ') &&
            (word.contains(w) ||
              w.contains(word) ||
              wordI.startsWith(w) ||
              w.startsWith(wordI) ||
              wI.contains(word) ||
              word.contains(wI));
        })
            .toSet()
            .toList();

        setState(() {
          relatedWords = {
            "synonyms": synonymData.map((item) => item['word'] as String).toList().isNotEmpty
            ? synonymData.map((item) => item['word'] as String).toList() : ['Không có từ đồng nghĩa'],
            "antonyms": antonymData.map((item) => item['word'] as String).toList().isNotEmpty
            ? antonymData.map((item) => item['word'] as String).toList() : ['Không có từ trái nghĩa'],
            "wordFamily": familyWords.isNotEmpty ? familyWords : ['Không có họ từ vựng'],
            "phrases": [' '],
          };
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      setState(() {
        relatedWords = {
          "synonyms": ['Không có từ đồng nghĩa'+ e.toString()],
          "antonyms": ['Không có từ trái nghĩa'],
          "wordFamily": ['Không có họ từ vựng'],
          "phrases": [' '],
        };
        isLoading = false;
      });
    }

    final idioms = await fetchIdioms(word);

    setState(() {
      relatedWords['phrases'] = idioms.isNotEmpty ? idioms : ['Không có cụm từ'];
    });
  }

  Widget buildSection(String title, List<String> words) {
    if (words.isEmpty) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 5, width: MediaQuery.of(context).size.width-100),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: words.map((word) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SelectableText(
                  word,
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 20,)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSection("Từ đồng nghĩa", relatedWords["synonyms"]!),
          buildSection("Từ trái nghĩa", relatedWords["antonyms"]!),
          buildSection("Họ từ vựng", relatedWords["wordFamily"]!),
          buildSection("Cụm từ", relatedWords["phrases"]!),
        ],
      ),
    );
  }
}