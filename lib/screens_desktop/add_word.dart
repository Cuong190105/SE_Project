import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'home_desktop.dart';
import 'settings.dart';

class AddWord extends StatefulWidget {
  const AddWord({super.key});

  @override
  _AddWordState createState() => _AddWordState();
}
class _AddWordState extends State<AddWord> {


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
  String? _selectedTuLoai;
  final List<String> _dsTuLoai = ['Danh từ', 'Động từ', 'Tính từ', 'Trạng từ',
    'Giới từ', 'Liên từ', 'Thán từ', 'Đại từ', 'Từ hạn định'];
  List<Widget> meaningBoxes = [];

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
                                      'Thêm từ',
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
// Tạo âm thanh
class AddSoundButton extends StatefulWidget {

  final double size;
  final ValueNotifier<AudioPlayer> audioPlayer;

  const AddSoundButton({
    Key? key,
    required this.size,
    required this.audioPlayer,
  }) : super(key: key);
  @override
  _AddSoundButtonState createState() => _AddSoundButtonState();
}
class _AddSoundButtonState extends State<AddSoundButton> {

  late final ValueNotifier<AudioPlayer> _player;
  String? _filePath;
  String? _fileName;
  Duration? _duration;
  bool _isPlaying = false;

  Future<void> _pickAudioFile() async {
    final typeGroup = XTypeGroup(
      label: 'audio',
      extensions: ['mp3', 'wav', 'm4a', 'aac', 'ogg'],
    );

    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file != null) {
      try {
        await _player.value.stop(); // Dừng file cũ nếu có
        await _player.value.setFilePath(file.path);

        final duration = await _player.value.durationFuture;

        setState(() {
          _filePath = file.path;
          _fileName = file.name;
          _duration = duration;
          _isPlaying = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Đã chọn file âm thanh: ${file.name} thành công',
                style: TextStyle(color: Colors.white), // chữ trắng
              ),
              backgroundColor: Colors.blue,
            ),
        );

      } catch (e) {
        print('Lỗi khi tải file: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Không tải file âm thanh',
              style: TextStyle(color: Colors.white), // chữ trắng
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _togglePlayPause() async {
    if (_player.value.playing) {
      await _player.value.pause();
    } else {
      await _player.value.play();
    }
    setState(() {
      _isPlaying = _player.value.playing;
    });
  }

  Future<void> _toggleRePlay() async {
    if (_player.value.playing) {
      await _player.value.seek(Duration.zero);
      await _player.value.play();
    } else {
      await _player.value.play();
    }
  }

  @override
  void initState() {
    super.initState();
    _player = widget.audioPlayer;
    _player.value.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.amber.withOpacity(0.3),
      child: Row(
        children: [
          if (_filePath != null) ...[
            Container(
              //color: Colors.cyan,
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - widget.size,
              ),
              child: Text(
                "🎵 $_fileName",
                softWrap: true,
              ),
            ),

            SizedBox(width: 10),

            Text("🕒 ${_duration?.inSeconds ?? '...'} giây"),

            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: _togglePlayPause,
              tooltip: _isPlaying ? 'Tạm dừng' : 'Phát',
            ),
            IconButton(
              icon: Icon(Icons.replay),
              onPressed: _toggleRePlay,
              tooltip: 'Phát lại',
            ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () async {
                await _player.value.stop();

                final oldPlayer = _player.value;
                final newPlayer = AudioPlayer();
                _player.value = newPlayer;

                oldPlayer.dispose();

                setState(() {
                  _filePath = null;
                  _fileName = null;
                  _duration = null;
                  _isPlaying = false;
                });
              },
              tooltip: 'Xoá file',
            ),
          ],
          ElevatedButton.icon(
            onPressed: _pickAudioFile,
            icon: Icon(Icons.upload_file),
            label: Text("Chọn file âm thanh"),
          ),
        ],
      ),
    );
  }
}
// tạo hình ảnh
class InputSection extends StatefulWidget {
  final ValueNotifier<List<Uint8List>> images;

  const InputSection({Key? key, required this.images}) : super(key: key);
  @override
  State<InputSection> createState() => _InputSectionState();
}
class _InputSectionState extends State<InputSection> {

  late ValueNotifier<List<Uint8List>> images;

  bool _isHovering = false;

  @override
  void initState() {
    images = widget.images;
  }

  @override
  void dispose() {
    images.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? file = await openFile(
      acceptedTypeGroups: [XTypeGroup(label: 'images', extensions: ['jpg', 'png', 'jpeg'])],
    );
    if (file != null) {
      final Uint8List bytes = await file.readAsBytes();
      setState(() {
        widget.images.value.add(bytes); // cập nhật dữ liệu gốc
        widget.images.notifyListeners(); // thông báo thay đổi
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      widget.images.value.removeAt(index);
      widget.images.notifyListeners(); // cập nhật dữ liệu gốc
    });
  }

  @override
  Widget build(BuildContext context) {
    const double imageWidth = 120;
    const double imageHeight = 160;

    return ValueListenableBuilder<List<Uint8List>>(
      valueListenable: widget.images,
      builder: (context, images, _) {
        return Row(
          children: [
            SizedBox(width: 100),
            Expanded(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (int i = 0; i < images.length; i++)
                    Stack(
                      children: [
                        Container(
                          width: imageWidth,
                          height: imageHeight,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            color: Colors.grey.shade200,
                          ),
                          child: Image.memory(images[i], fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => _removeImage(i),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black54,
                              ),
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  MouseRegion(
                    onEnter: (_) => setState(() => _isHovering = true),
                    onExit: (_) => setState(() => _isHovering = false),
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: imageWidth,
                        height: imageHeight,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _isHovering ? Colors.blue : Colors.blue.shade100,
                            width: 2,
                          ),
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.add,
                            size: 40,
                            color: _isHovering ? Colors.blue : Colors.blue.shade100,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
