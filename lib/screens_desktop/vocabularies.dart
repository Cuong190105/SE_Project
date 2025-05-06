import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'add_word.dart';
import 'home_desktop.dart';
import 'settings.dart';
import 'package:http/http.dart' as http;

class Vocabularies extends StatefulWidget {
  const Vocabularies({super.key});

  @override
  _Vocabularies createState() => _Vocabularies();
}
class _Vocabularies extends State<Vocabularies> {

  late Future<List<Map<String, dynamic>>> _wordDetailsFuture;

  Future<ValueNotifier<Uint8List?>> fetchImage(String url) async {
    try {
      // Gửi yêu cầu tải hình ảnh từ URL
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Nếu tải thành công, trả về dữ liệu nhị phân của hình ảnh
        return ValueNotifier<Uint8List?>(response.bodyBytes);
      } else {
        // Nếu có lỗi khi tải hình ảnh
        print("Failed to load image: ${response.statusCode}");
        return ValueNotifier<Uint8List?>(null);
      }
    } catch (e) {
      print("Error fetching image: $e");
      return ValueNotifier<Uint8List?>(null);
    }
  }

  Future<List<Map<String, dynamic>>> parseWordDetails() async {
     List<Map<String, dynamic>> vocabularyList = [];
    await Future.delayed(Duration(seconds: 2)); // Mô phỏng chờ tải dữ liệu
     final image = ValueNotifier<List<Uint8List>>([]); // Khởi tạo list rỗng

     fetchImage('https://i.pravatar.cc/150').then((imageData) {
       if (imageData != null) {
         image.value = []; // Gán list mới chứa 1 ảnh
       }
     });
     final audioList = <ValueNotifier<AudioPlayer>>[
       ValueNotifier(AudioPlayer()),
       ValueNotifier(AudioPlayer()),
       ValueNotifier(AudioPlayer()),
     ];

     final data =  [
      {'word': 'applefffffffffffffffffffffffffffffff', 'type': ['Danh từ', 'Động từ'],
        'phonetic': [['/us1/','/uk1/'],['/us2/','/uk2/']],
        'audio' : [audioList, audioList],
        'meaning': ['quả táo','đu đubbbbbbbbbbbbbbbbbbhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhf'], 'example': [['v1','vd2'], ['v1','vd2']],
        'image': [image,image]},

      {'word': 'tomato', 'type': ['Danh từ', 'Động từ'],
        'phonetic': [['/us1/','/uk1/'],['/us2/','/uk2/']],
        'audio' : [audioList, audioList],
        'meaning': ['cà chua','đu đu'], 'example': [['v1','vd2'], ['v1','vd2']],
        'image': [image,image]},

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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VocabularyList(wordDetails: item),
                                    ),
                                  );
                                },

                                onEdit: ()  {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UpdateWord(vocabularyList: item,),
                                    ),
                                  );
                                },
                                onDelete: () {
                                  setState(() {
                                    vocabularyList.removeAt(index);
                                    _wordDetailsFuture = Future.value(vocabularyList);
                                    // xóa trên database
                                  });
                                },
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
            Expanded(
              child: Text(
                (meaning as List).join(' || '),
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                softWrap: true,
              ),
            ),
          ],
        ),
      );
  }
}
// xem từ
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

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    int streakCount = 5; // Đợi dữ liệu từ database
    bool _isHovering = false; // hiệu ứng khi di chuột trở về
    bool isHoveringIcon = false;

    final Map<String, dynamic> data = widget.wordDetails;
    final List types = data['type'];
    final List phonetics = data['phonetic'];
    final List audios = data['audio'];
    final List meanings = data['meaning'];
    final List examples = data['example'];
    final List images = data['image'];

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
          child: SingleChildScrollView (
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
                                    data['word'],
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

                ],
              ),
                ),
                const SizedBox(height: 10),

                Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child:  ListView.builder(
                        itemCount: types.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  types[index],
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _playPreloadedAudio(audios[index][0]),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.volume_up, size: 20, color: Colors.black),
                                          const SizedBox(width: 5),
                                          Text(
                                            'US: ${phonetics[index][0]}',
                                            style: const TextStyle(fontStyle: FontStyle.italic),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    GestureDetector(
                                      onTap: () => _playPreloadedAudio(audios[index][1]),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.volume_up, size: 20, color: Colors.black),
                                          const SizedBox(width: 5),
                                          Text(
                                            'UK: ${phonetics[index][1]}',
                                            style: const TextStyle(fontStyle: FontStyle.italic),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Nghĩa: ${meanings[index]}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                if (examples[index].isNotEmpty)
                                  ...examples[index]
                                      .map<Widget>((ex) => Text('• $ex', style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)))
                                      .toList()
                                else
                                  const Text('• Không có ví dụ', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                                const SizedBox(height: 10),
                                ValueListenableBuilder<List<Uint8List>>(
                                  valueListenable: images[index],
                                  builder: (context, imageList, _) {
                                    if (imageList.isNotEmpty) {
                                      return Image.memory(imageList[0]);
                                    } else {
                                      return const Text("Chưa có ảnh");
                                    }
                                  },
                                ),
                                const Divider(),
                              ],
                            ),
                          );
                        },
                      ),
                    )

            ]
          ),
           ),
        ),
      ),
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
}
// sửa từ
class UpdateWord extends StatefulWidget {
  final Map<String, dynamic> vocabularyList;
  const UpdateWord({super.key, required this.vocabularyList});

  @override
  _UpdateWordState createState() => _UpdateWordState();
}
class _UpdateWordState extends State<UpdateWord> {
  late Map<String, dynamic> vocabularyList;

  late TextEditingController wordController;
  final List<ValueNotifier<String>> selectedTypes = [];
  final List<List<TextEditingController>> phoneticControllers = [];
  final List<List<ValueNotifier<AudioPlayer>>> audioPlayers = [];
  final List<TextEditingController> meaningControllers = [];
  final List<List<TextEditingController>> exampleControllers = [];
  final List<ValueNotifier<List<Uint8List>>> images = [];
  final TextEditingController synonym = TextEditingController();
  final TextEditingController antonym = TextEditingController();
  final TextEditingController family = TextEditingController();
  final TextEditingController phrase = TextEditingController();
  final List<Map<String, dynamic>> means = [];
  String? _selectedTuLoai;
  final List<String> _dsTuLoai = ['Danh từ', 'Động từ', 'Tính từ', 'Trạng từ',
    'Giới từ', 'Liên từ', 'Thán từ', 'Đại từ', 'Từ hạn định'];
  List<Widget> meaningBoxes = [];

  @override
  void initState() {
    super.initState();
    vocabularyList = widget.vocabularyList;
    wordController = TextEditingController(text: vocabularyList['word'] ?? '');
    synonym.text = vocabularyList['synonym'] ?? '';
    antonym.text = vocabularyList['antonym'] ?? '';
    family.text = vocabularyList['family'] ?? '';
    phrase.text = vocabularyList['phrase'] ?? '';
    _loadExistingData();
  }


  @override
  void dispose() {

    wordController.dispose();

    for (final phoneticPair in phoneticControllers) {
      for (final controller in phoneticPair) {
        controller.dispose();
      }
    }

    for (final controller in meaningControllers) {
      controller.dispose();
    }

    for (final exampleList in exampleControllers) {
      for (final controller in exampleList) {
        controller.dispose();
      }
    }

    for (final playerPair in audioPlayers) {
      for (final player in playerPair) {
        player.dispose();
      }
    }

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int streakCount = 5; // Đợi dữ liệu từ database
    bool _isHovering = false; // hiệu ứng khi di chuột trở về
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
                        onEnter: (_) => setState(() => isHoveringIcon = true),
                        onExit: (_) => setState(() => isHoveringIcon = false),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const HomeScreenDesktop()),
                                  (route) => false,
                            );
                          },
                          customBorder: const CircleBorder(), // Để hiệu ứng nhấn bo tròn đúng hình
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: isHoveringIcon ? Colors.grey.shade300 : Colors.white, // Hover đổi màu
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Settings(userId: 1)),
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
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
                                      'Sửa từ',
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
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Column(
                    children: [

                      // Từ vựng
                      TextField (
                        controller: wordController,
                        decoration: InputDecoration(
                          hintText: 'Từ vựng',
                          hintStyle: TextStyle(color: Colors.blue.shade300),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue), // Viền xanh khi chưa focus
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 2.0), // Viền xanh khi focus
                          ),
                        ),
                        maxLines: 1, // Không cho xuống dòng
                      ),
                      SizedBox(height: 10, width: screenWidth),

                      ...meaningBoxes,
                      SizedBox(height: 5, width: screenWidth),

                      // xóa thêm nghĩa
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 110), // cách viền trái
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _removeNewMeaningBox();
                                });
                              },
                              child: Text('Xóa ý nghĩa'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 25), // cách viền phải
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _addNewMeaningBox();
                                });
                              },
                              child: Text('Thêm ý nghĩa'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10, width: screenWidth),

                      __buildLabeledTextField('Từ đồng nghĩa', controller: synonym),
                      SizedBox(height: 10, width: screenWidth),
                      __buildLabeledTextField('Từ trái nghĩa', controller: antonym),
                      SizedBox(height: 10, width: screenWidth),
                      __buildLabeledTextField('Họ từ vựng', controller: family),
                      SizedBox(height: 10, width: screenWidth),
                      __buildLabeledTextField('Cụm từ', controller: phrase),
                      SizedBox(height: 10, width: screenWidth),

                      ElevatedButton(
                        onPressed: () {
                          printData();
                          // đẩy dữ liệu, dữ liệu lưu cục bộ
                        },
                        child: Text('Lưu từ vựng'),
                      ),
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
  // từ loại
  Widget typeWord() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Từ loại: ',
          style: TextStyle(fontSize: 16, color: Colors.blue.shade900, fontWeight: FontWeight.bold,),
        ),
        SizedBox(width: 8),
        // Nút chọn từ loại với hiệu ứng hover
        DropdownButton<String>(
          hint: Text("Chọn từ loại", style: TextStyle(fontSize: 16, color: Colors.blue.shade900),),
          value: _selectedTuLoai,
          items: _dsTuLoai.map((loai) {
            return DropdownMenuItem(
              value: loai,
              child: Text(loai),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedTuLoai = value;
            });
          },
          //underline: SizedBox(), // Ẩn đường gạch dưới mặc định
        ),
      ],
    );
  }
  //phiêm âm
  Widget transcription(
      String name,
       {required ValueNotifier<AudioPlayer> audioPlayer,
        required TextEditingController controller,
      }) {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [

        Text(
          name,
          style: TextStyle(fontSize: 16, color: Colors.blue.shade900, fontWeight: FontWeight.bold,),
        ),

        SizedBox(width: 8),

        Container(
          width: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade100,
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              //hintText: 'Nhập ${label.toLowerCase()}...',
              hintStyle: TextStyle(color: Colors.blue.shade300),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),

        // Phiên âm
        SizedBox(width: 8),
        AddSoundButton(size: 861, audioPlayer: audioPlayer,),
      ],
    );
  }
  // ô nghĩa và ví dụ
  Widget meaningBox(
      {
        required ValueNotifier<String> selectedType,
        required TextEditingController meaningController,
        required TextEditingController example1Controller,
        required TextEditingController example2Controller,
        required TextEditingController phoneticUkController,
        required TextEditingController phoneticUsController,
        required List<ValueNotifier<AudioPlayer>> audioPlayers,
        required ValueNotifier<List<Uint8List>> imageByte,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Loại từ
          ValueListenableBuilder<String>(
            valueListenable: selectedType,
            builder: (context, value, _) {
              return DropdownButton<String>(
                hint: Text("Chọn từ loại", style: TextStyle(fontSize: 16, color: Colors.blue.shade900)),
                value: value.isEmpty ? null : value,
                items: _dsTuLoai.map((loai) {
                  return DropdownMenuItem(
                    value: loai,
                    child: Text(loai),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedType.value = value!;
                },
              );
            },
          ),

          SizedBox(height: 10),

          // Phiên âm UK
          transcription('Phiên âm UK:',audioPlayer:  audioPlayers[0], controller: phoneticUkController),
          SizedBox(height: 10),

          // Phiên âm US
          transcription('Phiên âm US:',audioPlayer:  audioPlayers[1], controller: phoneticUsController),
          SizedBox(height: 10),

          // Nghĩa + nút âm thanh
          Row(
            children: [
              Expanded(child: _buildLabeledTextField('Nghĩa', controller: meaningController)),
              SizedBox(width: 8),
              AddSoundButton(size: 900, audioPlayer: audioPlayers[2],),
            ],
          ),
          SizedBox(height: 10),

          // Ví dụ
          _buildLabeledTextField('Ví dụ 1', controller: example1Controller),
          SizedBox(height: 10),
          _buildLabeledTextField('Ví dụ 2', controller: example2Controller),
          SizedBox(height: 10),

          Center(child: InputSection(images: imageByte,)),
        ],
      ),
    );
  }
  void _addNewMeaningBox() {
    final Map<String, dynamic> mean= {};
    final TextEditingController  meaningController = TextEditingController();
    final TextEditingController example1Controller = TextEditingController();
    final TextEditingController example2Controller = TextEditingController();
    final TextEditingController phoneticUsController = TextEditingController();
    final TextEditingController phoneticUkController = TextEditingController();
    final selectedType = ValueNotifier<String>("");
    final List<ValueNotifier<AudioPlayer>> audioPlayer
    = [ValueNotifier(AudioPlayer()), ValueNotifier(AudioPlayer()), ValueNotifier(AudioPlayer())];
    final ValueNotifier<List<Uint8List>> image =  ValueNotifier([]);
    setState(() {

      meaningBoxes.add(meaningBox(
          selectedType: selectedType,
          meaningController: meaningController,
          example1Controller: example1Controller,
          example2Controller: example2Controller,
          phoneticUkController: phoneticUkController,
          phoneticUsController: phoneticUsController,
          audioPlayers: audioPlayer,
          imageByte: image));

      selectedTypes.add(selectedType);
      phoneticControllers.add([phoneticUkController, phoneticUsController]); // Phiên âm UK và US
      audioPlayers.add(audioPlayer); //  cho UK và US và nghĩa
      meaningControllers.add(meaningController); // Điều khiển nghĩa
      exampleControllers.add([example1Controller, example2Controller]); // Ví dụ 1 và ví dụ 2
      images.add(image); // Điều khiển cho URL hình ảnh

      mean['type'] = selectedType.value;
      List<TextEditingController> phoneticsList = [phoneticUsController, phoneticUkController];
      mean['phonetic'] = phoneticsList;
      mean['meaning'] = meaningController;
      List<TextEditingController> examplesList = [example1Controller, example2Controller];
      mean['example'] = examplesList;
      mean['audio'] = audioPlayer;

      means.add(mean);

    });
  }
  void _loadExistingData() {
    final types = vocabularyList['type'] as List<dynamic>?;
    final phonetics = vocabularyList['phonetic'] as List<dynamic>?;
    final meanings = vocabularyList['meaning'] as List<dynamic>?;
    final examples = vocabularyList['example'] as List<dynamic>?;
    final audios = vocabularyList['audio'] as List<dynamic>?;
    final images0 = vocabularyList['image'] as List<dynamic>?;

    if (types != null &&
        phonetics != null &&
        meanings != null &&
        examples != null &&
        audios != null &&
        images0 != null &&
        types.length == meanings.length) {
      for (int i = 0; i < types.length; i++) {
        final type = ValueNotifier<String>(types[i] ?? "");
        final phoneticUs = TextEditingController(text: phonetics[i][0] ?? "");
        final phoneticUk = TextEditingController(text: phonetics[i][1] ?? "");
        final meaning = TextEditingController(text: meanings[i] ?? "");
        final example1 = TextEditingController(text: (examples[i] as List?)?.elementAt(0) ?? "");
        final example2 = TextEditingController(text: (examples[i] as List?)?.elementAt(1) ?? "");

        final audioPair = audios[i] as List<ValueNotifier<AudioPlayer>>;
        final audioNotifiers = [
          ValueNotifier(audioPair[0].value),
          ValueNotifier(audioPair[1].value),
          ValueNotifier(audioPair[2].value)
        ];

        // Cập nhật phần xử lý image
        final image = images0[i] as ValueNotifier<List<Uint8List>>; // Lấy ValueNotifier

        setState(() {
          meaningBoxes.add(meaningBox(
            selectedType: type,
            meaningController: meaning,
            example1Controller: example1,
            example2Controller: example2,
            phoneticUkController: phoneticUk,
            phoneticUsController: phoneticUs,
            audioPlayers: audioNotifiers,
            imageByte: image, // Chỉ hiển thị ảnh nếu có
          ));

          selectedTypes.add(type);
          phoneticControllers.add([phoneticUk, phoneticUs]);
          meaningControllers.add(meaning);
          exampleControllers.add([example1, example2]);
          audioPlayers.add(audioNotifiers);
          images.add(image); // Thêm vào danh sách images
          means.add({
            'type': type.value,
            'phonetic': [phoneticUs, phoneticUk],
            'meaning': meaning,
            'example': [example1, example2],
            'audio': audioNotifiers,
          });
        });
      }
    } else {
      _addNewMeaningBox();
    }
  }


  void _removeNewMeaningBox() {
    if (means.isEmpty || meaningBoxes.length == 1) return;

    setState(() {
      // Lấy dữ liệu cuối cùng
      final mean = means.removeLast();

      // Giải phóng các controller văn bản
      (mean['meaning'] as TextEditingController).dispose();
      for (var controller in mean['example'] as List<TextEditingController>) {
        controller.dispose();
      }
      for (var controller in mean['phonetic'] as List<TextEditingController>) {
        controller.dispose();
      }

      // Giải phóng AudioPlayer
      for (var player in mean['audio'] as List<AudioPlayer>) {
        player.dispose();
      }

      // Xóa khỏi các danh sách liên quan
      meaningControllers.removeLast();
      exampleControllers.removeLast();
      phoneticControllers.removeLast();
      audioPlayers.removeLast();
      images.removeLast();
      selectedTypes.removeLast();
      meaningBoxes.removeLast();
    });
  }

  // vd
  Widget _buildLabeledTextField(String label,  {required TextEditingController controller}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox( // Cố định chiều rộng phần label
          width: 90, // Bạn có thể điều chỉnh phù hợp
          child: Text(
            '$label:',
            style: TextStyle(fontSize: 16, color: Colors.blue.shade900, fontWeight: FontWeight.bold,),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100,
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                //hintText: 'Nhập ${label.toLowerCase()}...',
                hintStyle: TextStyle(color: Colors.blue.shade300),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ),
      ],
    );
  }
  // đồng, trái nghĩa
  Widget __buildLabeledTextField(String label, {required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(fontSize: 16, color: Colors.blue.shade900, fontWeight: FontWeight.bold,),
        ),
        SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade100,
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 10),
          child:  TextField(
            controller: controller,
            decoration: InputDecoration(
              hintStyle: TextStyle(color: Colors.blue.shade300),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> printData() async {

    print('wordController: ${wordController.text}');

    for (int i = 0; i < selectedTypes.length; i++) {
      print('\nselectedTypes[$i]: ${selectedTypes[i].value}');

      for (int j = 0; j < phoneticControllers[i].length; j++) {
        final controller = phoneticControllers[i][j];
        print('phoneticControllers[$i][$j]: ${controller.text}');
      }

      for (int j = 0; j < audioPlayers[i].length; j++) {
        final player = audioPlayers[i][j];

        // Kiểm tra duration để xác nhận đã có âm thanh
        final duration = await player.value.duration;
        if (duration == null) {
          print('audioPlayers[$i][$j] has no audio loaded');
        } else {
          print('audioPlayers[$i][$j] has audio, duration: $duration');
        }
      }

      print('meaningControllers[$i]: ${meaningControllers[i].text}');

      for (int j = 0; j < exampleControllers[i].length; j++) {
        final controller = exampleControllers[i][j];
        print('exampleControllers[$i][$j]: ${controller.text}');
      }

          print("image: Có ${images[i].value.length} ảnh:");

    }

    print('synonymController: ${synonym.text}');
    print('antonymController: ${antonym.text}');
    print('familyController: ${family.text}');
    print('phraseController: ${phrase.text}');

  }

}

