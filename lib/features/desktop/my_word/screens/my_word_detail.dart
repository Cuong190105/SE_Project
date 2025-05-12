import 'package:flutter/material.dart';
import 'package:eng_dictionary/features/common/widgets/streak_count.dart';
import 'package:eng_dictionary/features/common/widgets/setting_button.dart';
import 'package:eng_dictionary/features/common/widgets/logo_small.dart';
import 'package:eng_dictionary/features/common/widgets/back_button.dart';
import 'package:just_audio/just_audio.dart';

// xem từ
class WordDetails extends StatefulWidget {
  final Map<String, dynamic> wordDetails;
  const WordDetails({
    Key? key,
    required this.wordDetails,
  }) : super(key: key);

  @override
  _WordDetailsState createState() => _WordDetailsState();
}
class _WordDetailsState extends State<WordDetails> {
  int selectedIndex = 0;
  late List<List<AudioPlayer>> audiosPlayer;
  late final List<List<String>> audiosUrl;


  @override
  void initState() {
    super.initState();

    // Chuyển dữ liệu audio thành List<List<String>> an toàn
    audiosUrl = (widget.wordDetails['audio'] as List?)
        ?.map<List<String>>((e) => List<String>.from(e))
        .toList() ??
        [];

    // Nếu danh sách audio rỗng, thêm ít nhất 1 nhóm trống
    if (audiosUrl.isEmpty) {
      audiosUrl = [[], [], []];
    }

    // Tạo 3 AudioPlayer cho mỗi nhóm, bất kể url có đủ hay không
    audiosPlayer = List.generate(
      audiosUrl.length,
          (_) => List.generate(3, (_) => AudioPlayer()),
    );

    Future.delayed(Duration.zero, () async {
      await _loadAudios(); // Tải âm thanh
      setState(() {}); // Cập nhật giao diện sau khi tải âm thanh xong
    });
  }

  @override
  void dispose() {
    // Giải phóng tài nguyên khi widget bị hủy
    for (var playerList in audiosPlayer) {
      for (var player in playerList) {
        player.dispose(); // Hủy mỗi AudioPlayer
      }
    }
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    int streakCount = 5; // Đợi dữ liệu từ database

    final Map<String, dynamic> data = widget.wordDetails;

    final List types = data['type'] ?? [];
    final List phonetics = data['phonetic'] ?? [];

    final List meanings = data['meaning'] ?? [];
    final List examples = data['example'] ?? [];
    final List images = data['image'] ?? [];

    final List<String> synonym = data['synonym'] != null
        ? toSafeStringList(data['synonym'].split(RegExp(r'[,\s]+')))
        : [];
    final List<String> antonym = data['antonym'] != null
        ? toSafeStringList(data['antonym'].split(RegExp(r'[,\s]+')))
        : [];
    final List<String> family = data['family'] != null
        ? toSafeStringList(data['family'].split(RegExp(r'[,\s]+')))
        : [];
    final List<String> phrase = data['phrase'] != null
        ? toSafeStringList(data['phrase'].split(RegExp(r'[,]+')))
        : [];


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
        leadingWidth: screenWidth,
        leading: Stack(
          children: [
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
          child: Stack(
            children: [
          Positioned(
            left: 10,
            top: 10,
            child: CustomBackButton(content: widget.wordDetails['word']),
          ),
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
                  SizedBox(width: screenWidth / 5),
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
              Expanded(
                child: selectedIndex == 0
                    ? ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          itemCount: types.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        types[index],
                                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 15),
                                      GestureDetector(
                                        onTap: () => _playAudio(audiosPlayer[index][0]),
                                        child: const Icon(Icons.volume_up, size: 20),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => _playAudio(audiosPlayer[index][0]),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.volume_up, size: 20),
                                            const SizedBox(width: 5),
                                            Text('US: ${phonetics[index][0]}', style: const TextStyle(fontStyle: FontStyle.italic)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      GestureDetector(
                                        onTap: () => _playAudio(audiosPlayer[index][1]),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.volume_up, size: 20),
                                            const SizedBox(width: 5),
                                            Text('UK: ${phonetics[index][1]}', style: const TextStyle(fontStyle: FontStyle.italic)),
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
                                    ...examples[index].map<Widget>(
                                          (ex) => Text('• $ex', style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                                    )
                                  else
                                    const Text('• Không có ví dụ', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                                  const SizedBox(height: 10),
                                  Image.network(images[index]),
                                  const Divider(),
                                ],
                              ),
                            );
                          },
                        )
                    : SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildSection("Từ đồng nghĩa", synonym!),
                              buildSection("Từ trái nghĩa", antonym!),
                              buildSection("Họ từ vựng", family!),
                              buildSection("Cụm từ", phrase!),
                            ],
                          ),
                        ),

              ),
            ],
          ),
          ],
        ),
        ),
      ),

    );

  }

  Future<void> _loadAudios() async {
    for(int i = 0; i < audiosUrl.length; i++) {
      await _audios(audiosUrl[i], audiosPlayer[i]);
    }
  }
  Future<void> _audios(List<String> audiosUrl, List<AudioPlayer> players) async {
    try {
      for (int i = 0; i < audiosUrl.length; i++) {
        await players[i].setUrl(audiosUrl[i]);
      }
    } catch (e) {
      print('Lỗi thêm âm thanh: $e');
    }

  }
  Future<void> _playAudio(AudioPlayer player) async {
    try {
      if (player.playing) {
        await player.seek(Duration.zero);
      } else {
        await player.seek(Duration.zero);
        await player.play();
      }
    } catch (e) {
      print('Lỗi phát âm thanh: $e');
    }
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

  List<String> toSafeStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    } else if (value is String) {
      return [value];
    }
    return [];
  }
}