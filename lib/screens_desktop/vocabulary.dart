import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:process_run/shell.dart';
import 'dart:async';
import 'search.dart';
import 'home_desktop.dart';
import 'translate.dart';
//import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:file_selector/file_selector.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'add_word.dart';

class Vocabulary extends StatefulWidget {
  final String word;

  const Vocabulary({Key? key, required this.word}) : super(key: key);

  @override
  _VocabularyState createState() => _VocabularyState();
}
class _VocabularyState extends State<Vocabulary> {
  TextEditingController _controller = TextEditingController();
  int selectedIndex = 0;
  late final VocabularyList _vocabularyList;
  late final RelatedWordsList _relatedWordsList;

  @override
  void initState() {
    super.initState();
    _vocabularyList = VocabularyList(word: widget.word);
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
    int streakCount = 5; // Placeholder for streak count
    bool _isHovering = false; // Hover effect flag
    bool isHoveringIcon = false; // Hover effect for icon

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
        leadingWidth: screenWidth,
        leading: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'DICTIONARY',
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  // Your back button with hover effect (no changes needed here)
                  StatefulBuilder(
                    builder: (context, setState) {
                      return MouseRegion(
                        onEnter: (_) => setState(() => isHoveringIcon = true),
                        onExit: (_) => setState(() => isHoveringIcon = false),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const HomeScreenDesktop()),
                                  (route) => false,  // Điều này sẽ loại bỏ toàn bộ các trang trong stack
                            );
                          },
                          customBorder: const CircleBorder(),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: isHoveringIcon ? Colors.grey.shade300 : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.shade100,
                                  blurRadius: 2,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.book,
                              size: 20,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
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
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle),
              child: Icon(Icons.person, color: Colors.blue.shade700, size: 20),
            ),
            onPressed: () {},
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

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            return MouseRegion(
                              onEnter: (_) => setState(() => _isHovering = true),
                              onExit: (_) => setState(() => _isHovering = false),
                              child: Material(
                                color: _isHovering ? Colors.grey.shade300 : Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  borderRadius: BorderRadius.circular(30),
                                  splashColor: Colors.blue.withOpacity(0.2),
                                  highlightColor: Colors.blue.withOpacity(0.1),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        buttonBack(context),
                                        const SizedBox(width: 8),
                                        Text(
                                          widget.word,
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade700,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    ],
                  ),
                ]
            ),
          ),
        ),
      ),
    );
  }

  Widget buttonBack(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        icon: Icon(Icons.arrow_back, size: 30, color: Colors.blue.shade700),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreenDesktop()),
          );
        },
        hoverColor: Colors.grey.shade300.withOpacity(0),
      ),
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
    'Danh từ', 'Động từ', 'Tính từ', 'Trạng từ', 'Ngoại động từ', 'Nội động từ',
    'Giới từ', 'Liên từ', 'Thán từ', 'Đại từ', 'Từ hạn định', 'Cách phát âm'
  ];
  late final AudioPlayer _player;

  Future<String> downloadAudioFile(String audioUrl) async {
    try {
      // Lấy đường dẫn đến thư mục lưu trữ bền vững của ứng dụng
      final appDir = await getApplicationDocumentsDirectory();
      final filePath = '${appDir.path}/audio.oog'; // Tên file âm thanh

      // Tải file từ internet
      final dio = Dio();
      await dio.download(audioUrl, filePath);

      return filePath; // Trả về đường dẫn đến file đã tải
    } catch (e) {
      print('Lỗi tải âm thanh: $e');
      return '';
    }
  }

  Future<void> _playPreloadedAudio(AudioPlayer player) async {
    try {
      await player.seek(Duration.zero); // đảm bảo phát từ đầu
      await player.play();
    } catch (e) {
      print('Lỗi phát âm thanh: $e');
    }
  }

  Future<String> fetchWordDetails(String word) async {
    final url = 'https://vi.wiktionary.org/wiki/$word';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Tải dữ liệu thất bại');
    }
  }

  Future<String> fetchWordEnglishDetails(String word) async {
    final url = 'https://en.wiktionary.org/wiki/$word';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Tải dữ liệu thất bại');
    }
  }

  Future<List<Map<String, dynamic>>> parseWordDetails(String htmlContent, String htmlContentEnglish) async {
    final document = html_parser.parse(htmlContent);
    //print(phonetic(extractUlAfterPronunciationHeading(htmlContentEnglish),'Động từ', '', ''));
    //print(phonetic(extractUlAfterPronunciationHeading(htmlContentEnglish),'Danh từ', '', ''));
    final documentEnglish = html_parser.parse(extractUlAfterPronunciationHeading(htmlContentEnglish));
    final wordDetails = <Map<String, dynamic>>[];

    String phoneticUS = 'Không rõ phiên âm';
    String phoneticUK = 'Không rõ phiên âm';

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

        if(partOfSpeech=='Cách phát âm') {
          final phoneticElements = sectionElements[i].querySelectorAll('.IPA');

          if(!phoneticElements.isEmpty) {
            phoneticUK = phoneticElements.first.text.trim();
            phoneticUS = phoneticElements.last.text.trim();
          }
          continue;
        }
        wordDetail['type'] = partOfSpeech;

        List<String> phonetics = [];
        // Lấy phiên âm (nếu có)
        final phoneticElements = sectionElements[i].querySelectorAll('.IPA');
        if(!phoneticElements.isEmpty) {
          phoneticUK = phonetic(extractUlAfterPronunciationHeading(htmlContentEnglish)
              , partOfSpeech, phoneticElements.first.text.trim(), 'UK');
          phoneticUS = phonetic(extractUlAfterPronunciationHeading(htmlContentEnglish)
              , partOfSpeech, phoneticElements.last.text.trim(), 'US');
        } else {
          phoneticUK = phonetic(extractUlAfterPronunciationHeading(htmlContentEnglish)
              , partOfSpeech, phoneticUK, 'UK');
          phoneticUS = phonetic(extractUlAfterPronunciationHeading(htmlContentEnglish)
              , partOfSpeech, phoneticUS, 'US');
        }

        phonetics.add(phoneticUS);
        phonetics.add(phoneticUK);
        wordDetail['phonetic'] = phonetics;

        //final audioSources = documentEnglish.querySelectorAll('source');
        //String audioUrlUK = await audio(extractUlAfterPronunciationHeading(htmlContentEnglish), partOfSpeech, 'UK');
        //String audioUrlUS = await audio(extractUlAfterPronunciationHeading(htmlContentEnglish), partOfSpeech, 'US');

        final audios = await audioList(extractUlAfterPronunciationHeading(htmlContentEnglish), partOfSpeech);
        final audioUrlUK = audios[0];
        final audioUrlUS = audios[1];
        final playerUK = AudioPlayer();
        final playerUS = AudioPlayer();

        try {
          await playerUK.setUrl(audioUrlUK);
          await playerUS.setUrl(audioUrlUS);
          wordDetail['audio'] = [playerUS, playerUK];  // preload xong
        } catch (e) {
          print('Không thể tải audio: $e');
        }

        // Lấy nghĩa của từ (<li>)
        final olMeaningElement = sectionElements[i].querySelector('ol');
        if (olMeaningElement != null) {
          final meaningElements = olMeaningElement.querySelectorAll('li');
        List<String> meanings = [];
        List<List<String>> examples = [];

        for (var meaningElement in meaningElements) {
          String meaningText = '';
          List<String> examplesText = [];
          // lọc nghĩa
          //final aElements = meaningElement.querySelectorAll('a');
          String allText = meaningElement.text.trim();
          final dlElement = meaningElement.querySelector('dl');
          if (dlElement != null) {
            // Nếu có <dl>, loại bỏ text bên trong nó
            allText = allText.replaceAll(dlElement.text.trim(), '').trim();
          }
          // lọc vd
          final ddElements = meaningElement.querySelectorAll('dd');
          meaningText = allText;


          if (!meaningText.isNotEmpty) {
            //meaningText = meaningText.substring(0, meaningText.length - 2);
            continue;
          }

          for (var ddElement in ddElements) {
            examplesText.add(ddElement.text.trim());
          }

          meanings.add(meaningText);
          examples.add(examplesText);
        }
        wordDetail['meaning'] = meanings;
        wordDetail['examples'] = examples;

        }
        else {
            final meaningElements = sectionElements[i].querySelectorAll('li');
            List<String> meanings = [];
            List<List<String>> examples = [];

            for (var meaningElement in meaningElements) {
              String meaningText = '';
              List<String> examplesText = [];
              // lọc nghĩa
              //final aElements = meaningElement.querySelectorAll('a');
              String allText = meaningElement.text.trim();
              final dlElement = meaningElement.querySelector('dl');
              if (dlElement != null) {
                // Nếu có <dl>, loại bỏ text bên trong nó
                allText = allText.replaceAll(dlElement.text.trim(), '').trim();
              }
              // lọc vd
              final ddElements = meaningElement.querySelectorAll('dd');
              meaningText = allText;


              if (!meaningText.isNotEmpty) {
                //meaningText = meaningText.substring(0, meaningText.length - 2);
                continue;
              }

              for (var ddElement in ddElements) {
                examplesText.add(ddElement.text.trim());
              }

              meanings.add(meaningText);
              examples.add(examplesText);
            }
            wordDetail['meaning'] = meanings;
            wordDetail['examples'] = examples;
        }

        // Thêm chi tiết từ vào danh sách
        wordDetails.add(wordDetail);
      }
    }


    return wordDetails;
  }

  Future<List<Map<String, dynamic>>> _loadWordDetails() async {
    try {
      final htmlContent = await fetchWordDetails(widget.word);
      final htmlContentEnglish = await fetchWordEnglishDetails(widget.word);
      return parseWordDetails(htmlContent, htmlContentEnglish);
    } catch (e) {
      print('Lỗi khi tải dữ liệu: $e');
      return [];
    }
  }

  String extractUlAfterPronunciationHeading(String htmlContent) {
    final document = html_parser.parse(htmlContent);
    final headingDivs = document.querySelectorAll('div.mw-heading');

    for (var div in headingDivs) {
      final h3 = div.querySelector('h3#Pronunciation');
      if (h3 != null) {
        // Tìm phần tử kế tiếp của div này (không phải toàn bộ cây DOM)
        final parent = div.parent;
        if (parent != null) {
          final children = parent.children;
          final index = children.indexOf(div);

          if (index != -1 && index + 1 < children.length) {
            final nextEl = children[index + 1];
            if (nextEl.localName == 'ul') {
              return nextEl.outerHtml;
            }
          }
        }
      }
    }

    return '';
  }

  String phonetic(String html, String tuLoai, String oldp, String nation) {
    String type = chuyenTuLoaiSangTiengAnh(tuLoai);
    final document = html_parser.parse(html); // html là <ul>...</ul>

    final ul = document.body?.children.first; // chính là <ul>
    if (ul == null) return oldp;

    for (var li in ul.children.where((e) => e.localName == 'li')) {
      final spans = li.children.where((child) => child.localName == 'span').toList();
      if (spans.isEmpty) continue;

      final span = spans.first;
      final spanText = span.text.trim();
      if (spanText.contains(type)) {
        final ipaSpan = li.querySelector('.IPA');
        return ipaSpan?.text.trim() ?? oldp;
      } else if (spans.length > 1) {
        final span2 = spans[1];
        final spanText2 = span2.text.trim();
        if (spanText2.contains(nation)) {
          final ipaSpan = li.querySelector('.IPA');
          return ipaSpan?.text.trim() ?? oldp;
        } else {
          continue;
        }
      }
    }

    // Nếu không có li nào chứa đúng loại từ, lấy bất kỳ phiên âm nào nếu có
    final ipa = ul.querySelector('.IPA');
    return ipa != null ? ipa.text.trim() : oldp;
  }

  Future<String> audio(String html, String tuLoai,  String nation) async{
    final document = html_parser.parse(html);

    String audioUrl = '';
    String type = chuyenTuLoaiSangTiengAnh(tuLoai);

    final ul = document.body?.children.first;
    if (ul == null) return '';

    for (var li in ul.children.where((e) => e.localName == 'li')) {
      final spans = li.children.where((child) => child.localName == 'span')
          .toList();
      if (spans.isEmpty) continue;

        final span = spans.first;
        final spanText = span.text.trim();
        if (spanText.contains(type)) {
          final audioSources = li.querySelectorAll('source');
          if (audioSources.isNotEmpty) {
            print('1');
            audioUrl = audioSources.first.attributes['src'] ?? '';
            if (audioUrl.isNotEmpty && !audioUrl.startsWith('http')) {
              audioUrl = 'https:$audioUrl';

            }
            // Kiểm tra xem link có dùng được không
            try {
              final test = await http.get(Uri.parse(audioUrl));
              if(test.statusCode == 200 ) {
                return audioUrl;
              } else  {
                throw Exception('Audio URL not valid');
              }
            } catch (_) {
              audioUrl = ''; // Không dùng nếu lỗi
            }
          }
        } else if (spans.length > 1) {
          final span2 = spans[1];
          final spanText2 = span2.text.trim();
          if (spanText2.contains(nation)) {
            print(li.text);
            final audioSources = li.querySelectorAll('source');
            if (audioSources.isNotEmpty) {
              print('2');
              audioUrl = audioSources.first.attributes['src'] ?? '';
              if (audioUrl.isNotEmpty && !audioUrl.startsWith('http')) {
                audioUrl = 'https:$audioUrl';
              }
              // Kiểm tra xem link có dùng được không
              try {
                final test = await http.get(Uri.parse(audioUrl));

                if(test.statusCode == 200 ) {
                  return audioUrl;
                } else  {
                  throw Exception('Audio URL not valid');
                }
              } catch (_) {
                audioUrl = ''; // Không dùng nếu lỗi
              }
            }
          } else if (!spanText2.contains('UK')){
            final audioSources = li.querySelectorAll('source');
            print(li.text);
            if (audioSources.isNotEmpty) {

              print('3');
              audioUrl = audioSources.first.attributes['src'] ?? '';
              if (audioUrl.isNotEmpty && !audioUrl.startsWith('http')) {
                audioUrl = 'https:$audioUrl';

              }
              // Kiểm tra xem link có dùng được không
              try {
                final test = await http.get(Uri.parse(audioUrl));
                if(test.statusCode == 200 ) {
                  return audioUrl;
                } else  {
                  throw Exception('Audio URL not valid');
                }
              } catch (_) {
                audioUrl = ''; // Không dùng nếu lỗi
              }
            }
          }
        }
    }

    final audioSources = document.querySelectorAll('source');
    if (audioSources.isNotEmpty) {
      audioUrl = audioSources.first.attributes['src'] ?? '';
      if (audioUrl.isNotEmpty && !audioUrl.startsWith('http')) {
        audioUrl = 'https:$audioUrl';
      }
      // Kiểm tra xem link có dùng được không
      try {
        final test = await http.get(Uri.parse(audioUrl));
        if(test.statusCode == 200 ) {
          return audioUrl;
        } else  {
          throw Exception('Audio URL not valid');
        }
      } catch (_) {
        audioUrl = ''; // Không dùng nếu lỗi
      }
    }
    return audioUrl;
  }

  Future<List<String>> audioList(String html, String tuLoai) async {
    final document = html_parser.parse(html);
    List<String> listAudioUrl = ['', ''];
    int idex = 0;

    String type = chuyenTuLoaiSangTiengAnh(tuLoai);
    final ul = document.body?.children.first;
    if (ul == null) return listAudioUrl;

    Future<String> validateAudioUrl(String url) async {
      if (url.isEmpty) return '';
      if (!url.startsWith('http')) url = 'https:$url';

      try {
        final res = await http.get(Uri.parse(url));
        return res.statusCode == 200 ? url : '';
      } catch (_) {
        return '';
      }
    }

    for (var li in ul.children.where((e) => e.localName == 'li')) {
      final spans = li.children.where((child) => child.localName == 'span').toList();
      if (spans.isEmpty) continue;

      final spanText = spans.first.text.trim();
      print(spanText);
      if (spanText.contains(type)) {
        print(spanText + ' ' + type + ' ' + li.text);
        final audioSources = li.querySelectorAll('source');
        if (audioSources.isNotEmpty) {
          String temp = await validateAudioUrl(audioSources.first.attributes['src'] ?? '');
          if (temp.isNotEmpty && idex < listAudioUrl.length) {
            listAudioUrl[idex++] = temp;
            listAudioUrl[idex++] = temp;
          }
          if (idex == 2) return listAudioUrl;
        }
      } else if (spans.length > 1) {
        final spanText2 = spans[1].text.trim();
        if (spanText2.contains('UK') || spanText2.contains('US')) {
          final audioSources = li.querySelectorAll('source');
          if (audioSources.isNotEmpty) {
            String temp = await validateAudioUrl(audioSources.first.attributes['src'] ?? '');
            if (temp.isNotEmpty && idex < listAudioUrl.length) {
              listAudioUrl[idex++] = temp;
            }
            if (idex == 2) return listAudioUrl;
          }
        } else {
          final audioSources = li.querySelectorAll('source');
          if (audioSources.isNotEmpty) {
            String temp = await validateAudioUrl(audioSources.first.attributes['src'] ?? '');
            if (temp.isNotEmpty && idex < listAudioUrl.length) {
              listAudioUrl[idex++] = temp;
            }
            if (idex == 2) return listAudioUrl;
          }
        }
      }
    }

    // Fallback nếu không tìm thấy gì
    final audioSources = document.querySelectorAll('source');
    if (audioSources.isNotEmpty) {
      String temp = await validateAudioUrl(audioSources.first.attributes['src'] ?? '');
      if (temp.isNotEmpty) {
        listAudioUrl[0] = temp;
        listAudioUrl[1] = temp;
      }
    }
    print('ôd');
    return listAudioUrl;
  }

  String chuyenTuLoaiSangTiengAnh(String tuLoai) {
    final Map<String, String> _tuLoaiMap = {
      'Danh từ': 'noun',
      'Động từ': 'verb',
      'Tính từ': 'adjective',
      'Trạng từ': 'adverb',
      'Ngoại động từ': 'verb',
      'Nội động từ': 'verb',
      'Giới từ': 'preposition',
      'Liên từ': 'conjunction',
      'Thán từ': 'interjection',
      'Đại từ': 'pronoun',
      'Từ hạn định': 'determiner',
      'Cách phát âm': 'pronunciation',
    };

    return _tuLoaiMap[tuLoai] ?? '';
  }

  @override
  void initState() {
    super.initState();
    _wordDetails = _loadWordDetails();
    _player = AudioPlayer();
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _wordDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'.replaceAll('Exception: ','')));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Không tìm thấy dữ liệu'),
                SizedBox(height: 20), // Khoảng cách giữa Text và icon
                GestureDetector(
                  onTap: () {
                    // Điều hướng đến trang thêm từ
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddWord()),
                    );
                  },
                  child: Tooltip(
                    message: 'Đi đến trang thêm từ', // Nội dung tooltip khi di chuột
                    child: Icon(
                      Icons.add_circle_outline, // Biểu tượng thêm
                      size: 50, // Kích thước của biểu tượng
                      color: Colors.blue, // Màu sắc của biểu tượng
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          final data = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final wordType = data[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Từ loại
                    Text(
                      '${wordType['type']}',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5, width: MediaQuery.of(context).size.width-100),
                    // Phát âm
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if(!'${wordType['audio']}'.isEmpty) _playPreloadedAudio(wordType['audio'][0]);
                          }, // US audio
                          child: Row(
                            children: [
                              Icon(Icons.volume_up, size: 20,
                                  color: '${wordType['audio']}'.isEmpty ? Colors.grey: Colors.black),
                              SizedBox(width: 5),
                              Text(
                                'US: ${wordType['phonetic'][0]}',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 15),
                        GestureDetector(
                          onTap: () async {
                            if(!'${wordType['audio']}'.isEmpty) _playPreloadedAudio(wordType['audio'][1]);
                          },
                          child: Row(
                            children: [
                              Icon(Icons.volume_up, size: 20,
                                  color: '${wordType['audio']}'.isEmpty ? Colors.grey: Colors.black),
                              SizedBox(width: 5),
                              Text(
                                'UK: ${wordType['phonetic'][1]}',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
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
                                    '• $example',
                                    style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                                  ),
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
