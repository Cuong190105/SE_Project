import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'add_word.dart';
import 'home_desktop.dart';
import 'settings.dart';
class Vocabularies extends StatefulWidget {
  const Vocabularies({super.key});

  @override
  _Vocabularies createState() => _Vocabularies();
}
class _Vocabularies extends State<Vocabularies> {

  late Future<List<Map<String, dynamic>>> _wordDetailsFuture;


  Future<List<Map<String, dynamic>>> parseWordDetails() async {
     List<Map<String, dynamic>> vocabularyList = [];
    await Future.delayed(Duration(seconds: 2)); // Mô phỏng chờ tải dữ liệu
    final data =  [
      {'word': 'applefffffffffffffffffffffffffffffff', 'type': ['Danh từ', 'Động từ'],
        'phonetic': [['/us1/','uk1'],['/us2/','uk2']],
        'audio' : [[AudioPlayer(), AudioPlayer()],[AudioPlayer(), AudioPlayer()]],
        'meaning': ['quả táo','đu đu'], 'example': [['v1','vd2'], ['v1','vd2']],
        'imageUrl': ['https://i.pravatar.cc/150','https://i.pravatar.cc/151']},

      {'word': 'tomato', 'type': ['Danh từ', 'Động từ'],
        'phonetic': [['/us1/','uk1'],['/us2/','uk2']],
        'audio' : [[AudioPlayer(), AudioPlayer()],[AudioPlayer(), AudioPlayer()]],
        'meaning': ['cà chua','đu đu'], 'example': [['v1','vd2'], ['v1','vd2']],
        'imageUrl': ['https://i.pravatar.cc/150','https://i.pravatar.cc/151']},

      // Thêm nhiều từ khác...
    ];
    vocabularyList = data;
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
    int streakCount = 5; // Đợi dữ liệu từ database
    bool _isHovering = false; // hiệu ứng khi di chuột trở về
    bool _isHoveringT = false; // hiệu ứng khi di chuột trở về
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
                              onEnter: (_) =>
                                  setState(() => isHoveringIcon = true),
                              onExit: (_) =>
                                  setState(() => isHoveringIcon = false),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (
                                        context) => const HomeScreenDesktop()),
                                        (
                                        route) => false, // Điều này sẽ loại bỏ toàn bộ các trang trong stack
                                  );
                                },
                                customBorder: const CircleBorder(),
                                // Để hiệu ứng nhấn bo tròn đúng hình
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: isHoveringIcon
                                        ? Colors.grey.shade300
                                        : Colors.white, // Hover đổi màu
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
                  /*Align(
              alignment: Alignment.center,
              child: Container(
                width: screenWidth / 2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.blue.shade100, blurRadius: 5, spreadRadius: 1),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: IconButton(
                      icon: Icon(Icons.search, color: Colors.blue.shade700),
                      onPressed: () {},
                    ),
                    hintText: 'Nhập từ cần tìm kiếm',
                    hintStyle: TextStyle(color: Colors.blue.shade300),
                    border: InputBorder.none,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),*/
                ],
              ),
              actions: [
                Row(
                  children: [
                    Text(
                      "$streakCount",
                      style: const TextStyle(fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const Icon(
                        Icons.local_fire_department, color: Colors.orange,
                        size: 32),
                  ],
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.blue.shade100, shape: BoxShape.circle),
                    child: Icon(
                        Icons.person, color: Colors.blue.shade700, size: 20),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          Settings(userId: 1)),
                    );
                  },
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Row(
                        children: [
                          // Phần bên trái: nút quay lại + tiêu đề
                          StatefulBuilder(
                            builder: (context, setState) {
                              return MouseRegion(
                                onEnter: (_) =>
                                    setState(() => _isHovering = true),
                                onExit: (_) =>
                                    setState(() => _isHovering = false),
                                child: Material(
                                  color: _isHovering
                                      ? Colors.grey.shade300
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(30),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    borderRadius: BorderRadius.circular(30),
                                    splashColor: Colors.blue.withOpacity(0.2),
                                    highlightColor: Colors.blue.withOpacity(
                                        0.1),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 4.0),
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

                          // Spacer đẩy nút + sang phải
                          Spacer(),
                          // Nút dấu cộng
                          add_button(context),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

              FutureBuilder<List<Map<String, dynamic>>>(
                future: _wordDetailsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  }
                  else {
                    final vocabularyList = List<Map<String, dynamic>>.from(snapshot.data!);
                    return Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 16,
                            runSpacing: 16,
                            children: vocabularyList.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;

                              return SizedBox(
                                width: 250,
                                child: VocabularyCard(
                                  word: item['word'] ?? '',
                                  meaning: item['meaning'] ?? '',
                                  onView: () {
                                    // TODO: xử lý sửa
                                  },
                                  onEdit: () {
                                    // TODO: xử lý sửa
                                  },
                                  onDelete: () {
                                    setState(() {
                                      vocabularyList.removeAt(index);
                                      _wordDetailsFuture = Future.value(vocabularyList);
                                    });
                                    // TODO: cập nhật lên database nếu cần
                                  },
                                ),
                              );
                            }).toList(),
                          ),
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

  // Nút quay lại
  Widget buttonBack(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft, // Canh về góc trái trên
      child: IconButton(
        icon: Icon(Icons.arrow_back, size: 30, color: Colors.blue.shade700),
        onPressed: () {
          Navigator.pop(context); // Quay lại màn hình trước đó
        },

        hoverColor: Colors.grey.shade300.withOpacity(0),              // Màu nền khi di chuột vào
      ),
    );
  }
  // nút thêm từ
  Widget add_button(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddWord()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade500, // Nền xanh dương
        shape: CircleBorder(),        // Hình tròn
        padding: EdgeInsets.all(15),  // Kích thước nút
        elevation: 1,                 // Đổ bóng nhẹ
      ),
      child:  Icon(
        Icons.add,                    // Icon dấu +
        color: Colors.white,         // Màu trắng
        size: 32,                     // Kích thước icon
      ),
    );
  }
}
// thẻ từ vựng
class VocabularyCard extends StatelessWidget {
  final String word;
  final List<String> meaning;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const VocabularyCard({
    Key? key,
    required this.word,
    required this.meaning,
    this.onView,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
     return  Container(
        height: 150,
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    word,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'view' && onView != null) {
                      onView!();
                    } else if (value == 'edit' && onEdit != null) {
                      onEdit!();
                    } else if (value == 'delete' && onDelete != null) {
                      onDelete!();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text('Xem'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text('Sửa'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          const SizedBox(width: 8),
                          const Text('Xóa'),
                        ],
                      ),
                    ),
                  ],
                ),

              ],
            ),
            const SizedBox(height: 8),
            Text(
              (meaning as List).join(' || '),
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
              maxLines: 4,
            ),
          ],
        ),
      );
  }
}

class VocabularyList extends StatefulWidget {
  final Map<String, dynamic> wordDetails;

  const VocabularyList({
    Key? key,
    required this.wordDetails,
  }) : super(key: key);

  @override
  _VocabularyListState createState() => _VocabularyListState();
}
class _VocabularyListState extends State<VocabularyList> {

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.wordDetails.length,
      itemBuilder: (context, index) {
        final wordData = widget.wordDetails[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${wordData['type']}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _playPreloadedAudio(wordData['audio'][0]),
                    child: Row(
                      children: [
                        Icon(Icons.volume_up, size: 20, color: Colors.black),
                        const SizedBox(width: 5),
                        Text(
                          'US: ${wordData['phonetic'][0]}',
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: () => _playPreloadedAudio(wordData['audio'][1]),
                    child: Row(
                      children: [
                        Icon(Icons.volume_up, size: 20, color: Colors.black),
                        const SizedBox(width: 5),
                        Text(
                          'UK: ${wordData['phonetic'][1]}',
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(wordData['meaning'].length, (i) {
                  final examples = wordData['example'][i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nghĩa: ${wordData['meaning'][i]}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (examples.isNotEmpty)
                        ...examples.map<Widget>((ex) => Text('• $ex', style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic))).toList()
                      else
                        const Text('• Không có ví dụ', style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
                    ],
                  );
                }),
              ),
              const Divider(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _playPreloadedAudio(AudioPlayer player) async {
    try {
      await player.seek(Duration.zero); // đảm bảo phát từ đầu
      await player.play();
    } catch (e) {
      print('Lỗi phát âm thanh: $e');
    }
  }
}


