import 'package:flutter/material.dart';
import 'package:eng_dictionary/features/common/widgets/streak_count.dart';
import 'package:eng_dictionary/features/mobile/settings/widgets/setting_button.dart';
import 'package:eng_dictionary/features/common/widgets/back_button.dart';
import 'package:eng_dictionary/features/common/widgets/my_word/add_word_button.dart';
import 'package:eng_dictionary/features/common/widgets/logo_small.dart';
import 'package:eng_dictionary/features/desktop/my_word/widgets/vocabulary_card.dart';
import 'package:eng_dictionary/features/desktop/my_word/screens/add_word.dart';
import 'package:eng_dictionary/features/desktop/my_word/screens/my_word_detail.dart';
import 'package:eng_dictionary/features/desktop/my_word/screens/update_word.dart';

class MyWord extends StatefulWidget {
  const MyWord({super.key});

  @override
  _MyWord createState() => _MyWord();
}

class _MyWord extends State<MyWord> {
  late Future<List<ValueNotifier<Map<String, dynamic>>>> _wordDetailsFuture;

  Future<List<ValueNotifier<Map<String, dynamic>>>> parseWordDetails() async {
    List<ValueNotifier<Map<String, dynamic>>> vocabularyList = [];
    await Future.delayed(Duration(seconds: 2)); // Mô phỏng chờ tải dữ liệu

    final audioUrl =
        'https://upload.wikimedia.org/wikipedia/commons/5/52/En-us-hello.ogg';

    final data = [
      {
        'word': 'applefffffffffffffffffffffffffffffff',
        'type': ['Danh từ', 'Động từ'],
        'phonetic': [
          ['/us1/', '/uk1/'],
          ['/us2/', '/uk2/']
        ],
        'audio': [
          [audioUrl, audioUrl, audioUrl],
          [audioUrl, audioUrl, audioUrl]
        ],
        'meaning': [
          'quả táo',
          'đu đubbbbbbbbbbbbbbbbboooooooooooooo'
              'oooooooooooooooooooooooooooooooooooooooooooooooooooooo'
              'ooooooooooooooooooooooooooooooooooooooooooooooooooooooooo'
              'ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo'
              'ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo'
              'ooooooooooooooooooooooooooooooooooooooooooooooooohhhhhhhhhhhh'
              'hhhhhhhhhhhhhhhhhhhhhhhhhf'
        ],
        'example': [
          ['v1', 'vd2'],
          ['v1', 'vd2']
        ],
        'image': ['https://i.pravatar.cc/150', 'https://i.pravatar.cc/151'],
        'synonym': 'táo',
        'antonym': 'cam',
        'family': 'taos',
        'phrase': 'tao không dai, tao ddd',
      },
      {
        'word': 'tomato',
        'type': ['Động từ'],
        'phonetic': [
          ['/us2/', '/uk2/']
        ],
        'audio': [
          [audioUrl, audioUrl, audioUrl]
        ],
        'meaning': ['đu đu'],
        'example': [
          ['v1', 'vd2']
        ],
        'image': ['https://i.pravatar.cc/153']
      },
      {
        'word': 'tomato',
        'type': ['Động từ'],
        'phonetic': [
          ['/us2/', '/uk2/']
        ],
        'audio': [
          [audioUrl, audioUrl, audioUrl]
        ],
        'meaning': ['đu đu'],
        'example': [
          ['v1', 'vd2']
        ],
        'image': ['https://i.pravatar.cc/153']
      },
      {
        'word': 'tomato',
        'type': ['Động từ'],
        'phonetic': [
          ['/us2/', '/uk2/']
        ],
        'audio': [
          [audioUrl, audioUrl, audioUrl]
        ],
        'meaning': ['đu đu'],
        'example': [
          ['v1', 'vd2']
        ],
        'image': ['https://i.pravatar.cc/153']
      },
      {
        'word': 'tomato',
        'type': ['Động từ'],
        'phonetic': [
          ['/us2/', '/uk2/']
        ],
        'audio': [
          [audioUrl, audioUrl, audioUrl]
        ],
        'meaning': ['đu đu'],
        'example': [
          ['v1', 'vd2']
        ],
        'image': ['https://i.pravatar.cc/153']
      },
      {
        'word': 'tomato',
        'type': ['Động từ'],
        'phonetic': [
          ['/us2/', '/uk2/']
        ],
        'audio': [
          [audioUrl, audioUrl, audioUrl]
        ],
        'meaning': ['đu đu'],
        'example': [
          ['v1', 'vd2']
        ],
        'image': ['https://i.pravatar.cc/153']
      },
      {
        'word': 'tomato',
        'type': ['Động từ'],
        'phonetic': [
          ['/us2/', '/uk2/']
        ],
        'audio': [
          [audioUrl, audioUrl, audioUrl]
        ],
        'meaning': ['đu đu'],
        'example': [
          ['v1', 'vd2']
        ],
        'image': ['https://i.pravatar.cc/153']
      },
      {
        'word': 'tomato',
        'type': ['Động từ'],
        'phonetic': [
          ['/us2/', '/uk2/']
        ],
        'audio': [
          [audioUrl, audioUrl, audioUrl]
        ],
        'meaning': ['đu đu'],
        'example': [
          ['v1', 'vd2']
        ],
        'image': ['https://i.pravatar.cc/153']
      },
      {
        'word': 'tomato',
        'type': ['Động từ'],
        'phonetic': [
          ['/us2/', '/uk2/']
        ],
        'audio': [
          [audioUrl, audioUrl, audioUrl]
        ],
        'meaning': ['đu đu'],
        'example': [
          ['v1', 'vd2']
        ],
        'image': ['https://i.pravatar.cc/153']
      },

      // Thêm nhiều từ khác...
    ];
    vocabularyList =
        data.map((item) => ValueNotifier<Map<String, dynamic>>(item)).toList();
    return vocabularyList;
  }

  @override
  void initState() {
    super.initState();
    _wordDetailsFuture = parseWordDetails();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
        leadingWidth: screenWidth,
        leading: Stack(
          children: [
            CustomBackButton_(
              content: 'Kho từ vựng',
              color: Colors.blue,
            ),
            Center(
              child: LogoSmall(),
            ),
          ],
        ),
        actions: [
          StreakCount(),
          SettingButton(),
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    Spacer(),
                    AddWordButton(),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<ValueNotifier<Map<String, dynamic>>>>(
                  future: _wordDetailsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Lỗi: ${snapshot.error}'));
                    } else {
                      final vocabularyList =
                          List<ValueNotifier<Map<String, dynamic>>>.from(
                              snapshot.data!);
                      return Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 16,
                            runSpacing: 16,
                            children:
                                vocabularyList.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;

                              return SizedBox(
                                width: (screenWidth - 120) / 4,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WordDetails(
                                            wordDetails: item.value),
                                      ),
                                    );
                                  },
                                  child: VocabularyCard(
                                    word: item.value['word'] ?? '',
                                    meaning: item.value['meaning'] ?? '',
                                    onView: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => WordDetails(
                                              wordDetails: item.value),
                                        ),
                                      );
                                    },
                                    onEdit: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UpdateWord(
                                            vocabularyList: item.value,
                                          ),
                                        ),
                                      );
                                    },
                                    onDelete: () {
                                      setState(() {
                                        vocabularyList.removeAt(index);
                                        _wordDetailsFuture =
                                            Future.value(vocabularyList);
                                        // xóa trên database
                                      });
                                    },
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    }
                  }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
