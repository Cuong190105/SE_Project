import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:eng_dictionary/features/common/widgets/streak_count.dart';
import 'package:eng_dictionary/features/mobile/settings/widgets/setting_button.dart';
import 'package:eng_dictionary/features/common/widgets/back_button.dart';
import 'package:eng_dictionary/features/common/widgets/my_word/add_word_button.dart';
import 'package:eng_dictionary/features/common/widgets/logo_small.dart';
import 'package:eng_dictionary/features/desktop/my_word/widgets/vocabulary_card.dart';
import 'package:eng_dictionary/features/desktop/my_word/screens/add_word.dart';
import 'package:eng_dictionary/features/desktop/my_word/screens/my_word_detail.dart';
import 'package:eng_dictionary/features/common/widgets/back_button.dart';
import 'package:eng_dictionary/features/common/widgets/logo_small.dart';
import 'package:eng_dictionary/features/common/widgets/streak_count.dart';
import 'package:eng_dictionary/features/desktop/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:eng_dictionary/features/desktop/my_word/widgets/related_word.dart';
import 'package:eng_dictionary/features/desktop/my_word/widgets/meaning_box.dart';

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
  bool _isLoading = false;
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
    // Dispose các controller chính
    wordController.dispose();
    synonym.dispose();
    antonym.dispose();
    family.dispose();
    phrase.dispose();

    // Dispose các controller trong các box
    for (var controllers in phoneticControllers) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }

    for (var controller in meaningControllers) {
      controller.dispose();
    }

    for (var controllers in exampleControllers) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }

    // Dispose audio players
    for (var players in audioPlayers) {
      for (var player in players) {
        player.value.dispose();
        player.dispose();
      }
    }

    // Dispose notifiers
    for (var type in selectedTypes) {
      type.dispose();
    }
    for (var image in images) {
      image.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int streakCount = 5; // Đợi dữ liệu từ database

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
        leadingWidth: screenWidth,
        leading: Stack(
          children: [
            Center(
              child:LogoSmall(),
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
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: CustomBackButton(content: '${vocabularyList['word']}',),
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

                            RelatedWord(label: 'Từ đồng nghĩa', controller: synonym),
                            SizedBox(height: 10, width: screenWidth),
                            RelatedWord(label: 'Từ trái nghĩa', controller: antonym),
                            SizedBox(height: 10, width: screenWidth),
                            RelatedWord(label: 'Họ từ vựng', controller: family),
                            SizedBox(height: 10, width: screenWidth),
                            RelatedWord(label: 'Cụm từ', controller: phrase),
                            SizedBox(height: 10, width: screenWidth),

                            ElevatedButton(
                              onPressed: () {
                                if (wordController.text.isEmpty || meaningControllers == null || meaningControllers.isEmpty) {
                                  // Hiển thị thông báo lỗi
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Vui lòng điền từ vựng!',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: Colors.red, // Màu đỏ cho thông báo lỗi
                                    ),
                                  );
                                } else {
                                  // Nếu tất cả điều kiện hợp lệ, thực hiện lưu từ vựng
                                  _saveVocabulary();
                                  printData();
                                  // đẩy dữ liệu, dữ liệu lưu cục bộ ok
                                }
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
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5), // Màu đen mờ
                    child: Center(
                      child: CircularProgressIndicator(), // Vòng xoay
                    ),
                  ),
              ]
          ),
        ),
      ),
    );
  }

  // chuyển sang bytes
  Future<List<Uint8List>> fetchImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return [response.bodyBytes]; // trả về list chứa 1 ảnh
      } else {
        print("Failed to load image: ${response.statusCode}");
        return []; // trả về list rỗng nếu lỗi
      }
    } catch (e) {
      print("Error fetching image: $e");
      return []; // trả về list rỗng nếu lỗi
    }
  }

  // Hàm để bắt đầu lưu từ vựng
  Future<void> _saveVocabulary() async {
    setState(() {
      _isLoading = true; // Bật chế độ loading
    });

    try {
      // Mô phỏng hành động lưu từ vựng (chờ dữ liệu hoặc gửi yêu cầu)
      await Future.delayed(Duration(seconds: 2)); // Giả lập việc lưu dữ liệu (thực tế có thể là các hàm như gọi API)

      setState(() {
        _isLoading = false; // Tắt chế độ loading
      });

      // Điều hướng trở lại trang Home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreenDesktop()),
            (Route<dynamic> route) => false, // Loại bỏ tất cả các trang trước đó
      );

      // Thông báo thành công (nền xanh)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dữ liệu đã được lưu thành công!'),
          backgroundColor: Colors.blue, // Màu nền xanh khi thành công
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false; // Tắt chế độ loading nếu có lỗi
      });

      // Thông báo thất bại (nền đỏ)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lưu dữ liệu thất bại!'),
          backgroundColor: Colors.red, // Màu nền đỏ khi thất bại
        ),
      );
    }
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

  void _addNewMeaningBox() {
    final Map<String, dynamic> mean= {};
    final TextEditingController  meaningController = TextEditingController();
    final TextEditingController example1Controller = TextEditingController();
    final TextEditingController example2Controller = TextEditingController();
    final TextEditingController phoneticUsController = TextEditingController();
    final TextEditingController phoneticUkController = TextEditingController();
    final selectedType = ValueNotifier<String>("");

    final List<ValueNotifier<AudioPlayer>> audioPlayer = [
      ValueNotifier<AudioPlayer>(AudioPlayer()),  // Gán AudioPlayer đầu tiên
      ValueNotifier<AudioPlayer>(AudioPlayer()),  // Gán AudioPlayer thứ hai
      ValueNotifier<AudioPlayer>(AudioPlayer()),  // Gán AudioPlayer thứ ba
    ];
    final ValueNotifier<List<Uint8List>> image =  ValueNotifier([]);
    setState(() {

      meaningBoxes.add(MeaningBox(
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
    final images = vocabularyList['image'] as List<dynamic>?;

    if (types != null &&
        phonetics != null &&
        meanings != null &&
        examples != null &&
        audios != null &&
        images != null &&
        types.length == meanings.length) {

      for (int i = 0; i < types.length; i++) {
        final type = ValueNotifier<String>(types[i]);
        final meaning = TextEditingController(text: meanings[i]);

        // Phonetics
        final phoneticUs = TextEditingController(text: phonetics[i][0]);
        final phoneticUk = TextEditingController(text: phonetics[i][1]);

        // Examples
        final List<String> examplesList = List<String>.from(examples[i]);
        final example1 = TextEditingController(text: examplesList[0]);
        final example2 = TextEditingController(text: examplesList[1]);

        // Audio players
        final List<ValueNotifier<AudioPlayer>> audioPlayers = [
          ValueNotifier<AudioPlayer>(AudioPlayer()),
          ValueNotifier<AudioPlayer>(AudioPlayer()),
          ValueNotifier<AudioPlayer>(AudioPlayer())
        ];

        // Load audio URLs
        Future.delayed(Duration.zero, () async {
          try {
            for (int j = 0; j < audios[i].length && j < 3; j++) {
              await audioPlayers[j].value.setUrl(audios[i][j]);
            }
          } catch (e) {
            print('Error loading audio: $e');
          }
        });

        // Image bytes
        final imageBytes = ValueNotifier<List<Uint8List>>([]);
        if (i < images.length) {
          fetchImage(images[i]).then((bytes) {
            imageBytes.value = bytes;
          });
        }

        setState(() {
          meaningBoxes.add(MeaningBox(
            selectedType: type,
            meaningController: meaning,
            example1Controller: example1,
            example2Controller: example2,
            phoneticUkController: phoneticUk,
            phoneticUsController: phoneticUs,
            audioPlayers: audioPlayers,
            imageByte: imageBytes,
          ));

          selectedTypes.add(type);
          meaningControllers.add(meaning);
          phoneticControllers.add([phoneticUk, phoneticUs]);
          exampleControllers.add([example1, example2]);
          this.audioPlayers.add(audioPlayers);
          this.images.add(imageBytes);
        });
      }
    } else {
      _addNewMeaningBox();
    }
  }
  void _removeNewMeaningBox() {
    if (meaningBoxes.length <= 1) return;

    setState(() {
      // Xóa và dispose các controller
      final lastIndex = meaningBoxes.length - 1;

      // Dispose AudioPlayers
      for (var playerNotifier in audioPlayers[lastIndex]) {
        playerNotifier.value.dispose();
        playerNotifier.dispose();
      }

      // Dispose các controller khác
      for (var controller in phoneticControllers[lastIndex]) {
        controller.dispose();
      }
      meaningControllers[lastIndex].dispose();
      for (var controller in exampleControllers[lastIndex]) {
        controller.dispose();
      }

      // Xóa khỏi các list
      meaningBoxes.removeLast();
      selectedTypes.removeLast();
      phoneticControllers.removeLast();
      audioPlayers.removeLast();
      meaningControllers.removeLast();
      exampleControllers.removeLast();
      images.removeLast();
    });
  }

  Future<void> _loadAudios(List<List<String>> audiosUrl, List<List<AudioPlayer>> audioPlayers) async {

    for (int i = 0; i < audiosUrl.length; i++) {
      await _audios(audiosUrl[i], audioPlayers[i]);
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
