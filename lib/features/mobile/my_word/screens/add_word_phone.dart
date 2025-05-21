import 'package:eng_dictionary/features/common/widgets/back_button.dart';
import 'package:eng_dictionary/features/mobile/settings/widgets/setting_button.dart';
import 'package:eng_dictionary/features/common/widgets/streak_count.dart';
import 'package:eng_dictionary/features/mobile/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:eng_dictionary/features/mobile/my_word/widgets/related_word.dart';
import 'package:eng_dictionary/features/mobile/my_word/widgets/meaning_box.dart';
import 'package:eng_dictionary/core/services/cloud/google_drive_service.dart';
import 'package:eng_dictionary/core/services/cloud/drive_uploader.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:eng_dictionary/core/services/word_service.dart';

class AddWordPhone extends StatefulWidget {
  final List<ValueNotifier<Map<String, dynamic>>> vocabularyList;

  AddWordPhone({super.key, required this.vocabularyList});

  @override
  _AddWordState createState() => _AddWordState();
}

class _AddWordState extends State<AddWordPhone> {
  final wordController = TextEditingController();
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

  List<Widget> meaningBoxes = [];
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _addNewMeaningBox();
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

  Future<List<String>?> uploadMyImages(List<Uint8List> imageBytes) async {
    try {
      if (imageBytes.isEmpty) {
        throw Exception('Không có ảnh nào được chọn');
      }

      // Kiểm tra kết nối
      final driveApi = await GoogleDriveService.getDriveApi();
      if (driveApi == null) {
        throw Exception('Không thể kết nối với Google Drive');
      }

      final uploader = DriveUploader(driveApi);

      // Upload ảnh và lấy links
      final links = await uploader.uploadImages(imageBytes);
      print("Các link công khai: $links");
      return links;
    } catch (e) {
      print('Lỗi khi tải ảnh lên: $e');
      // Hiển thị thông báo lỗi cho người dùng
      throw Exception('Không thể tải ảnh lên. Vui lòng thử lại sau.');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
        leadingWidth: screenWidth,
        leading: Stack(
          children: [
            CustomBackButton_(
              content: 'Thêm từ',
              color: Colors.blue,
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
          child: Stack(children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Từ vựng
                        TextField(
                          controller: wordController,
                          decoration: InputDecoration(
                            hintText: 'Từ vựng',
                            hintStyle: TextStyle(color: Colors.blue.shade300),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          maxLines: 1,
                        ),
                        SizedBox(height: 10),

                        ...meaningBoxes,
                        SizedBox(height: 5),

                        // xóa thêm nghĩa
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _removeNewMeaningBox();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              child: Text('Xóa ý nghĩa'),
                            ),
                            SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _addNewMeaningBox();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              child: Text('Thêm ý nghĩa'),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),

                        RelatedWord(
                            label: 'Từ đồng nghĩa', controller: synonym),
                        SizedBox(height: 10),
                        RelatedWord(
                            label: 'Từ trái nghĩa', controller: antonym),
                        SizedBox(height: 10),
                        RelatedWord(label: 'Họ từ vựng', controller: family),
                        SizedBox(height: 10),
                        RelatedWord(label: 'Cụm từ', controller: phrase),
                        SizedBox(height: 15),

                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              if (wordController.text.isEmpty) {
                                // Hiển thị thông báo lỗi
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Vui lòng điền từ vựng!',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else {
                                //_saveVocabulary();
                                collectAndAddData();
                                //uploadMyImages(images[0].value);
                                //printData();
                                // đẩy dữ liệu, dữ liệu lưu cục bộ
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: Text('Lưu từ vựng'),
                          ),
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
          ]),
        ),
      ),
    );
  }

  // Hàm để bắt đầu lưu từ vựng
  Future<void> _saveVocabulary() async {
    setState(() {
      _isLoading = true; // Bật chế độ loading
    });

    try {
      // Mô phỏng hành động lưu từ vựng (chờ dữ liệu hoặc gửi yêu cầu)
      await Future.delayed(Duration(
          seconds:
              2)); // Giả lập việc lưu dữ liệu (thực tế có thể là các hàm như gọi API)

      setState(() {
        _isLoading = false; // Tắt chế độ loading
      });

      // Điều hướng trở lại trang Home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreenPhone()),
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

  void _addNewMeaningBox() {
    final Map<String, dynamic> mean = {};
    final TextEditingController meaningController = TextEditingController();
    final TextEditingController example1Controller = TextEditingController();
    final TextEditingController example2Controller = TextEditingController();
    final TextEditingController phoneticUsController = TextEditingController();
    final TextEditingController phoneticUkController = TextEditingController();
    final selectedType = ValueNotifier<String>("");
    final List<ValueNotifier<AudioPlayer>> audioPlayer = [
      ValueNotifier(AudioPlayer()),
      ValueNotifier(AudioPlayer())
    ];
    final ValueNotifier<List<Uint8List>> image = ValueNotifier([]);
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
      phoneticControllers.add(
          [phoneticUkController, phoneticUsController]); // Phiên âm UK và US
      audioPlayers.add(audioPlayer); //  cho UK và US và nghĩa
      meaningControllers.add(meaningController); // Điều khiển nghĩa
      exampleControllers
          .add([example1Controller, example2Controller]); // Ví dụ 1 và ví dụ 2
      images.add(image); // Điều khiển cho URL hình ảnh

      mean['type'] = selectedType.value;
      List<TextEditingController> phoneticsList = [
        phoneticUsController,
        phoneticUkController
      ];
      mean['phonetic'] = phoneticsList;
      mean['meaning'] = meaningController;
      List<TextEditingController> examplesList = [
        example1Controller,
        example2Controller
      ];
      mean['example'] = examplesList;
      mean['audio'] = audioPlayer;

      means.add(mean);
    });
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

      // Giải phóng AudioPlayer (dạng ValueNotifier)
      for (var playerNotifier
          in mean['audio'] as List<ValueNotifier<AudioPlayer>>) {
        playerNotifier.value.dispose(); // Dispose actual player
        playerNotifier.dispose(); // Dispose ValueNotifier nếu không tái sử dụng
      }

      // Giải phóng selectedType & imageByte nếu bạn tạo bằng ValueNotifier
      selectedTypes.removeLast().dispose();
      images.removeLast().dispose();

      // Xóa khỏi các danh sách liên quan
      meaningControllers.removeLast();
      exampleControllers.removeLast();
      phoneticControllers.removeLast();
      audioPlayers.removeLast();
      meaningBoxes.removeLast();
    });
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

  Future<void> collectAndAddData() async {
    String word = wordController.text;
    List<String> types =
        selectedTypes.map((typeNotifier) => typeNotifier.value).toList();

    List<List<String>> phonetics = [];
    List<List<String>> audioUrls = [];
    List<String> meanings = [];
    List<List<String>> examples = [];
    List<List<Uint8List>> imagesList = [];

    for (int i = 0; i < selectedTypes.length; i++) {
      // Phonetic
      phonetics.add(
          phoneticControllers[i].map((controller) => controller.text).toList());

      // Audio
      List<String> audioGroup = [];
      for (int j = 0; j < audioPlayers[i].length; j++) {
        final audioPlayer = audioPlayers[i][j];
        final audio =
            audioPlayer.value.audioSource?.sequence.first.tag ?? "no_audio_url";
        audioGroup.add(audio.toString());
      }
      audioUrls.add(audioGroup);

      // Meaning
      meanings.add(meaningControllers[i].text);

      // Example
      examples.add(
          exampleControllers[i].map((controller) => controller.text).toList());

      // Image
      imagesList.add(images[i].value);
    }

    // Build final map
    Map<String, dynamic> newWord = {
      'word': word,
      'type': types,
      'phonetic': phonetics,
      'meaning': meanings,
      'example': examples,
      'synonym': synonym.text,
      'antonym': antonym.text,
      'family': family.text,
      'phrase': phrase.text,
    };

    Map<String, dynamic> newWord1 = {
      'word_id': 1,
      'deleted': false,
      'word': 'cxdf',
      'definition': 'cxdf',
      'example': ['kbjif', 'kbjif'],
      'us_ipa': 'cxdf',
      'uk_ipa': 'cxdf',
      'synonym': [1, 2],
      'antonym': [1, 2],
      'family': [1, 2],
      'phrase': [1, 2],
    };
    final List<Map<String, dynamic>> vocabularyList1 = [newWord1];
    // Thêm vào vocabularyList
    widget.vocabularyList.add(ValueNotifier<Map<String, dynamic>>(newWord));
    await WordService.uploadWords(vocabularyList1,
        images: {}, usAudios: {}, ukAudios: {});
    print("✅ Dữ liệu đã được thêm vào vocabularyList.");
  }
}
