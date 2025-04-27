/*import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DictionaryService {
  static const String _baseUrl = 'https://api.dictionaryapi.dev/api/v2/entries/en/';

  // Hàm để gọi API và trả về kết quả từ điển
  Future<List<String>> fetchSuggestions(String query) async {
    final response = await http.get(Uri.parse(_baseUrl + query));

    if (response.statusCode == 200) {
      // Phân tích dữ liệu JSON từ API
      var data = json.decode(response.body);

      // Tạo danh sách gợi ý từ dựa trên dữ liệu trả về
      List<String> suggestions = [];
      if (data is List) {
        // Giả sử mỗi phần tử của 'data' chứa thông tin về một nghĩa từ
        for (var meaning in data[0]['meanings']) {
          if (meaning['partOfSpeech'] != null) {
            suggestions.add(meaning['partOfSpeech']);
          }
        }
      }

      return suggestions;
    } else {
      throw Exception('Failed to load suggestions');
    }
  }
}

class DictionaryScreen extends StatefulWidget {
  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dictionary Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter a word',
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                if (query.isNotEmpty) {
                  // Gọi API và cập nhật gợi ý từ
                  Provider.of<AutocompleteProvider>(context, listen: false)
                      .fetchSuggestions(query);
                } else {
                  // Nếu không có từ nhập vào, xóa gợi ý
                  Provider.of<AutocompleteProvider>(context, listen: false)
                      .clearSuggestions();
                }
              },
            ),
            SizedBox(height: 10),
            Consumer<AutocompleteProvider>(
              builder: (context, provider, child) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: provider.suggestions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(provider.suggestions[index]),
                        onTap: () {
                          _controller.text = provider.suggestions[index];
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AutocompleteProvider with ChangeNotifier {
  List<String> _suggestions = [];

  List<String> get suggestions => _suggestions;

  // Hàm để lấy gợi ý từ API
  Future<void> fetchSuggestions(String query) async {
    try {
      List<String> result = await DictionaryService().fetchSuggestions(query);
      _suggestions = result;
      notifyListeners();
    } catch (e) {
      print(e);
      _suggestions = [];
      notifyListeners();
    }
  }

  // Hàm để xóa gợi ý
  void clearSuggestions() {
    _suggestions = [];
    notifyListeners();
  }*/
