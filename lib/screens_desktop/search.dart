import 'package:flutter/material.dart';
import 'translate.dart';
import 'vocabularies.dart';
import 'vocabulary.dart';
import 'package:eng_dictionary/screens_desktop/authentic_desktop/register_screen.dart';
import 'settings.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Search extends StatefulWidget {

  TextEditingController controller = TextEditingController();

  Search({Key? key, required this.controller,}) : super(key: key);

  @override
  _Search createState() => _Search();
}
class _Search extends State<Search> {


  Future<List<String>>? _suggestions;
  Set<int> _hoveredIndexes = {};

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  void _searchWords(String query) {
    setState(() {
      _suggestions = fetchSuggestions(query);
    });
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
        // Nếu API trả về không phải danh sách
        throw Exception('Định dạng phản hồi API không hợp lệ');
      }
    } else {
      throw Exception('Không thể lấy được gợi ý');
    }
  }


  @override
  Widget build(BuildContext context) {

    return  Container(
      width: MediaQuery.of(context).size.width / 2,
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
      child: Column(
        children: [
          // TextField cho việc tìm kiếm
          TextField(
            controller: widget.controller,
            onChanged: (value) {
              _searchWords(value);
              setState(() {});
            },
            decoration: InputDecoration(
              prefixIcon: IconButton(
                icon: Icon(Icons.search, color: Colors.blue.shade700),
                onPressed: () {
                  final word = widget.controller.text;
                  widget.controller.text = '';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Vocabulary(word: word,),
                      ),
                    ).then((_) {
                      widget.controller.clear();
                    });
                },
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: Colors.blue.shade700),
                onPressed: () {
                  widget.controller.clear();
                  _searchWords(''); // Reset kết quả tìm kiếm
                  setState(() {}); // Cập nhật lại giao diện
                },
              ),

              hintText: 'Nhập từ cần tìm kiếm',
              hintStyle: TextStyle(color: Colors.blue.shade300),
              border: InputBorder.none,
            ),
            textAlign: TextAlign.center,
          ),


          Container(
            height: 1,
            color: Colors.grey.shade300,
          ),

          // Hiển thị kết quả tìm kiếm hoặc đề xuất từ
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
                    width: MediaQuery.of(context).size.width / 2,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    color: Colors.white,
                    child: Center(
                      child: Text('${snapshot.error}', style: TextStyle(color: Colors.red)),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final data = snapshot.data!;
                  return Container(
                    width: MediaQuery.of(context).size.width / 2,
                    color: Colors.white,
                    child: data.isEmpty
                        ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text('Không tìm thấy định nghĩa.', style: TextStyle(color: Colors.red)),
                      ),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final word = data[index];
                        final isHovered = _hoveredIndexes.contains(index);

                        return MouseRegion(
                          onEnter: (_) {
                            setState(() {
                              _hoveredIndexes.add(index);
                            });
                          },
                          onExit: (_) {
                            setState(() {
                              _hoveredIndexes.remove(index);
                            });
                          },
                          child: Container(
                            color: isHovered ? Colors.grey.shade300 : Colors.transparent,
                            child: ListTile(
                              title: Text(word),
                              onTap: () {
                                widget.controller.text = '';
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Vocabulary(word: word,),
                                  ),
                                ).then((_) {
                                  widget.controller.clear();
                                });
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