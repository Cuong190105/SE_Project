import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as dom;

void main() {
  runApp(const WiktionaryApp());
}

class WiktionaryApp extends StatelessWidget {
  const WiktionaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Wiktionary(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Wiktionary extends StatefulWidget {
  const Wiktionary({super.key});

  @override
  State<Wiktionary> createState() => _WiktionaryState();
}
class _WiktionaryState extends State<Wiktionary> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  List<String> _results = [];
  String? _error;

  Future<void> _searchWord(String word) async {
    setState(() {
      _isLoading = true;
      _results = [];
      _error = null;
    });

    final url = 'https://vi.wiktionary.org/w/rest.php/v1/page/$word/html';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        dom.Document document = htmlParser.parse(response.body);

        // Lấy toàn bộ text trong các thẻ <p>, <li>...
        List<String> texts = [];

        var pTags = document.getElementsByTagName('p');
        texts.addAll(pTags.map((e) => e.text.trim()));

        var liTags = document.getElementsByTagName('li');
        texts.addAll(liTags.map((e) => e.text.trim()));

        setState(() {
          _results = texts.where((element) => element.isNotEmpty).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Không tìm thấy từ "$word"';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi kết nối: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Từ điển Wiktionary API')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Nhập từ tiếng Anh...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _searchWord(_controller.text.trim());
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red))
            else if (_results.isEmpty)
                const Text('Nhập từ để tra cứu')
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _results[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
