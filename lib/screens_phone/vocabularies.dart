import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_word.dart';
import 'package:eng_dictionary/features/mobile/home/home_screen.dart';
import '../data/models/database_helper.dart';
import 'vocabulary_phone.dart';

class Vocabularies extends StatefulWidget {
  const Vocabularies({super.key});

  @override
  _Vocabularies createState() => _Vocabularies();
}

class _Vocabularies extends State<Vocabularies> {
  List<Word> _words = [];
  bool _isLoading = true;
  String? _errorMessage;
  int streakCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchStreakCount();
    _fetchWords();
  }

  Future<void> _fetchStreakCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      streakCount = prefs.getInt('streak_count') ?? 5;
    });
  }

  Future<void> _fetchWords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final words = await DatabaseHelper.instance.getWords();
      setState(() {
        _words = words;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tải danh sách từ vựng: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool _isHovering = false;
    bool isHoveringIcon = false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
        leadingWidth: screenWidth,
        leading: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  StatefulBuilder(
                    builder: (context, setState) {
                      return MouseRegion(
                        onEnter: (_) => setState(() => isHoveringIcon = true),
                        onExit: (_) => setState(() => isHoveringIcon = false),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const HomeScreenPhone()),
                                  (route) => false,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: [
                      StatefulBuilder(
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
                                        'Kho từ vựng',
                                        style: TextStyle(
                                          fontSize: 22,
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
                      Spacer(),
                      add_button(context),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      if (_isLoading)
                        Center(child: CircularProgressIndicator()),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                      if (!_isLoading && _words.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _words.length,
                          itemBuilder: (context, index) {
                            final word = _words[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text(
                                  word.word,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                subtitle: Text(
                                  word.partOfSpeech,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VocabularyPhone(word: word),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      if (!_isLoading && _words.isEmpty)
                        Center(child: Text('Chưa có từ vựng nào')),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
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
          Navigator.pop(context);
        },
        hoverColor: Colors.grey.shade300.withOpacity(0),
      ),
    );
  }

  Widget add_button(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddWord()),
        ).then((result) {
          if (result == true) {
            _fetchWords();
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade500,
        shape: CircleBorder(),
        padding: EdgeInsets.all(15),
        elevation: 1,
      ),
      child: Icon(
        Icons.add,
        color: Colors.white,
        size: 32,
      ),
    );
  }
}