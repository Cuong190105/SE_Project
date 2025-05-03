import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';
import 'package:eng_dictionary/back_end/services/word_service.dart';

import 'home_desktop.dart';
class AddWord extends StatefulWidget {
  const AddWord({super.key});

  @override
  _AddWordState createState() => _AddWordState();
}

class _AddWordState extends State<AddWord> {
  String? _selectedTuLoai;
  final List<String> _dsTuLoai = ['Danh từ', 'Động từ', 'Tính từ', 'Trạng từ',
    'Giới từ', 'Liên từ', 'Thán từ', 'Đại từ', 'Từ hạn định'];
  List<MeaningBoxController> meaningControllers = [];

  // Controllers cho các trường nhập liệu
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _synonymsController = TextEditingController();
  final TextEditingController _antonymsController = TextEditingController();
  final TextEditingController _wordFamilyController = TextEditingController();
  final TextEditingController _phrasesController = TextEditingController();

  // Lưu trữ đường dẫn tới các file media
  Map<String, File> _mediaFiles = {};

  // Trạng thái loading
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Thêm hộp nghĩa đầu tiên
    _addMeaningBox();
  }

  void _addMeaningBox() {
    setState(() {
      meaningControllers.add(MeaningBoxController());
    });
  }

  void _removeMeaningBox() {
    if (meaningControllers.length > 1) {
      setState(() {
        meaningControllers.removeLast();
      });
    }
  }

  // Xử lý lưu từ vựng
  Future<void> _saveWord() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Kiểm tra trường từ vựng không được để trống
      if (_wordController.text.trim().isEmpty) {
        _showErrorMessage('Vui lòng nhập từ vựng!');
        return;
      }

      // Kiểm tra từ loại
      if (_selectedTuLoai == null) {
        _showErrorMessage('Vui lòng chọn từ loại!');
        return;
      }

      // Tạo cấu trúc dữ liệu từ vựng
      List<Map<String, dynamic>> meanings = [];
      for (var controller in meaningControllers) {
        if (controller.meaningController.text.isNotEmpty) {
          Map<String, dynamic> meaning = {
            'meaning': controller.meaningController.text,
            'examples': [
              if (controller.example1Controller.text.isNotEmpty) controller.example1Controller.text,
              if (controller.example2Controller.text.isNotEmpty) controller.example2Controller.text,
            ]
          };
          meanings.add(meaning);
        }
      }

      if (meanings.isEmpty) {
        _showErrorMessage('Vui lòng nhập ít nhất một nghĩa cho từ vựng!');
        return;
      }

      // Chuẩn bị dữ liệu gửi lên server
      Map<String, dynamic> wordData = {
        'word': _wordController.text.trim(),
        'type': _selectedTuLoai,
        'meanings': meanings,
        'synonyms': _synonymsController.text.isEmpty ? [] : _synonymsController.text.split(',').map((e) => e.trim()).toList(),
        'antonyms': _antonymsController.text.isEmpty ? [] : _antonymsController.text.split(',').map((e) => e.trim()).toList(),
        'wordFamily': _wordFamilyController.text.isEmpty ? [] : _wordFamilyController.text.split(',').map((e) => e.trim()).toList(),
        'phrases': _phrasesController.text.isEmpty ? [] : _phrasesController.text.split(',').map((e) => e.trim()).toList(),
      };

      // Chuẩn bị files
      Map<int, File> images = {};
      Map<int, File> usAudios = {};
      Map<int, File> ukAudios = {};

      // Giả định wordId là 0 cho từ mới
      int tempWordId = 0;

      if (_mediaFiles.containsKey('ukAudio') && _mediaFiles['ukAudio'] != null) {
        ukAudios[tempWordId] = _mediaFiles['ukAudio']!;
      }

      if (_mediaFiles.containsKey('usAudio') && _mediaFiles['usAudio'] != null) {
        usAudios[tempWordId] = _mediaFiles['usAudio']!;
      }

      // Gọi API tải lên từ vựng
      final result = await WordService.uploadWords(
          [wordData],
          ukAudios: ukAudios.isNotEmpty ? ukAudios : null,
          usAudios: usAudios.isNotEmpty ? usAudios : null,
          images: images.isNotEmpty ? images : null
      );

      // Kiểm tra kết quả
      if (result.containsKey('errors') && (result['errors'] as List).isNotEmpty) {
        _showErrorMessage('Lỗi: ${result['errors'].toString()}');
      } else {
        _showSuccessMessage('Đã thêm từ vựng thành công!');
        _resetForm();
      }
    } catch (e) {
      _showErrorMessage('Đã xảy ra lỗi: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetForm() {
    setState(() {
      _wordController.clear();
      _selectedTuLoai = null;
      _synonymsController.clear();
      _antonymsController.clear();
      _wordFamilyController.clear();
      _phrasesController.clear();
      _mediaFiles.clear();

      meaningControllers.clear();
      _addMeaningBox();
    });
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    // Hủy tất cả controllers
    _wordController.dispose();
    _synonymsController.dispose();
    _antonymsController.dispose();
    _wordFamilyController.dispose();
    _phrasesController.dispose();

    for (var controller in meaningControllers) {
      controller.dispose();
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
                                  (route) => false,  // Điều này sẽ loại bỏ toàn bộ các trang trong stack
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
          child: Stack(
            children: [
              SingleChildScrollView(
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
                          TextField(
                            controller: _wordController,
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

                          // Từ loại
                          Row(
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
                              ),
                            ],
                          ),
                          SizedBox(height: 10, width: screenWidth),

                          // phiên âm
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Phiên âm UK: ',
                                style: TextStyle(fontSize: 16, color: Colors.blue.shade900, fontWeight: FontWeight.bold,),
                              ),

                              SizedBox(width: 8),
                              // Phiên âm
                              AddSoundButton(
                                onFileSelected: (file) {
                                  setState(() {
                                    _mediaFiles['ukAudio'] = file;
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10, width: screenWidth),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Phiên âm US: ',
                                style: TextStyle(fontSize: 16, color: Colors.blue.shade900, fontWeight: FontWeight.bold,),
                              ),

                              SizedBox(width: 8),
                              // Phiên âm
                              AddSoundButton(
                                onFileSelected: (file) {
                                  setState(() {
                                    _mediaFiles['usAudio'] = file;
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10, width: screenWidth),

                          // Các hộp nghĩa
                          ...meaningControllers.map((controller) => meaningBox(controller)).toList(),
                          SizedBox(height: 5, width: screenWidth),

                          // xóa thêm nghĩa
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 110), // cách viền trái
                                child: ElevatedButton(
                                  onPressed: _removeMeaningBox,
                                  child: Text('Xóa ý nghĩa'),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 25), // cách viền phải
                                child: ElevatedButton(
                                  onPressed: _addMeaningBox,
                                  child: Text('Thêm ý nghĩa'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10, width: screenWidth),

                          __buildLabeledTextField('Từ đồng nghĩa', _synonymsController,
                              hintText: 'Nhập các từ đồng nghĩa, phân cách bằng dấu phẩy'),
                          SizedBox(height: 10, width: screenWidth),
                          __buildLabeledTextField('Từ trái nghĩa', _antonymsController,
                              hintText: 'Nhập các từ trái nghĩa, phân cách bằng dấu phẩy'),
                          SizedBox(height: 10, width: screenWidth),
                          __buildLabeledTextField('Họ từ vựng', _wordFamilyController,
                              hintText: 'Nhập các từ cùng họ, phân cách bằng dấu phẩy'),
                          SizedBox(height: 10, width: screenWidth),
                          __buildLabeledTextField('Cụm từ', _phrasesController,
                              hintText: 'Nhập các cụm từ, phân cách bằng dấu phẩy'),
                          SizedBox(height: 10, width: screenWidth),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: _isLoading ? null : _saveWord,
                            child: Text(_isLoading ? 'Đang lưu...' : 'Lưu từ vựng'),
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Hiển thị loading overlay khi đang xử lý
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Column(
                    children: [

                      // Từ vựng
                      TextField(
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
                                    if (meaningBoxes.isNotEmpty && meaningBoxes.length > 1) {
                                      meaningBoxes.removeLast();
                                    }
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
                                    meaningBoxes.add(meaningBox());
                                  });
                                },
                                child: Text('Thêm ý nghĩa'),
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 10, width: screenWidth),

                      __buildLabeledTextField('Từ đồng nghĩa'),
                      SizedBox(height: 10, width: screenWidth),
                      __buildLabeledTextField('Từ trái nghĩa'),
                      SizedBox(height: 10, width: screenWidth),
                      __buildLabeledTextField('Họ từ vựng'),
                      SizedBox(height: 10, width: screenWidth),
                      __buildLabeledTextField('Cụm từ'),
                      SizedBox(height: 10, width: screenWidth),

                      ElevatedButton(
                        onPressed: () {
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

  // ô nghĩa và ví dụ
  Widget meaningBox(MeaningBoxController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabeledTextField('Nghĩa', controller.meaningController),
          SizedBox(height: 10),
          _buildLabeledTextField('Ví dụ 1', controller.example1Controller),
          SizedBox(height: 10),
          _buildLabeledTextField('Ví dụ 2', controller.example2Controller),
        ],
      ),
    );
  }

  Widget _buildLabeledTextField(String label, TextEditingController controller) {
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
                hintStyle: TextStyle(color: Colors.blue.shade300),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
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

  // đồng, trái nghĩa
  Widget __buildLabeledTextField(String label, TextEditingController controller, {String? hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(fontSize: 16, color: Colors.blue.shade900, fontWeight: FontWeight.bold,),
        ),
        SizedBox(height: 5),
        Container(
  //phiêm âm
  Widget transcription(String name) {
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
              hintText: hintText,
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
}

// Lớp quản lý các trường nhập nghĩa
class MeaningBoxController {
  final TextEditingController meaningController = TextEditingController();
  final TextEditingController example1Controller = TextEditingController();
  final TextEditingController example2Controller = TextEditingController();

  void dispose() {
    meaningController.dispose();
    example1Controller.dispose();
    example2Controller.dispose();
  }
}

// Tạo âm thanh
class AddSoundButton extends StatefulWidget {
  final Function(File) onFileSelected;

  const AddSoundButton({Key? key, required this.onFileSelected}) : super(key: key);

  @override
  _AddSoundButtonState createState() => _AddSoundButtonState();
}

class _AddSoundButtonState extends State<AddSoundButton> {
  final AudioPlayer _player = AudioPlayer();
  String? _filePath;
  String? _fileName;
  Duration? _duration;
  bool _isPlaying = false;
  bool _isLoading = false;

  Future<void> _pickAudioFile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final typeGroup = XTypeGroup(
        label: 'audio',
        extensions: ['mp3', 'wav', 'm4a', 'aac'],
      );

      final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);

      if (file != null) {
        try {
          String filePath = file.path;

          // Kiểm tra và sửa lỗi URL-encoded
          if (filePath.contains('%3A')) {
            filePath = Uri.decodeFull(filePath);
          }
          // Tạo file từ đường dẫn đã chọn
          final audioFile = File(filePath);

          // Kiểm tra xem file có tồn tại không
          if (!await audioFile.exists()) {
            throw Exception('File không tồn tại');
          }

          // Dừng file cũ nếu có
          await _player.stop();

          // Thiết lập đường dẫn file cho player
          await _player.setFilePath(filePath);

          // Lấy thời lượng của file audio
          final duration = await _player.durationFuture;

          setState(() {
            _filePath = filePath;
            _fileName = file.name;
            _duration = duration;
            _isPlaying = false;
          });

          // Gọi callback để thông báo file đã được chọn
          widget.onFileSelected(audioFile);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Đã chọn file âm thanh: ${file.name} thành công',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.blue,
            ),
          );
        } catch (e) {
          print('Lỗi khi xử lý file: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Không thể xử lý file âm thanh: ${e.toString()}',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Lỗi khi chọn file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi khi chọn file âm thanh: ${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
      setState(() {
        _isPlaying = _player.playing;
      });
    } catch (e) {
      print('Lỗi khi phát/dừng âm thanh: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể phát file âm thanh',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          if (_filePath != null) ...[
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 580,
              ),
              child: Text(
                "🎵 $_fileName",
                softWrap: true,
              ),
            ),

            const SizedBox(width: 10),

            Text("🕒 ${_duration?.inSeconds ?? '...'} giây"),

            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: _togglePlayPause,
              tooltip: _isPlaying ? 'Tạm dừng' : 'Phát',
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                await _player.stop();
                setState(() {
                  _filePath = null;
                  _fileName = null;
                  _duration = null;
                  _isPlaying = false;
                });

                // Reset file đã chọn với null để thông báo đã xóa
                widget.onFileSelected(File(''));
              },
              tooltip: 'Xoá file',
            ),
          ],
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton.icon(
            onPressed: _pickAudioFile,
            icon: const Icon(Icons.upload_file),
            label: const Text("Chọn file âm thanh"),
          ),
        ],
      ),
    );
  }
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
        AddSoundButton(size: 821,),
      ],
    );
  }
  // ô nghĩa và ví dụ
  Widget meaningBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          typeWord(),
          SizedBox(height: 10),
          transcription('Phiên âm UK: '),
          SizedBox(height: 10),
          transcription('Phiên âm US: '),
          SizedBox(height: 10),
          Row (
          children: [
            Expanded(
                child: _buildLabeledTextField('Nghĩa')),
                SizedBox(width: 8),
                AddSoundButton(size: 900),
          ]
          ),
          SizedBox(height: 10),
          _buildLabeledTextField('Ví dụ 1'),
          SizedBox(height: 10),
          _buildLabeledTextField('Ví dụ 2'),
          SizedBox(height: 10),
          Center(child: InputSection(),),
        ],
      ),
    );
  }
  // vd
  Widget _buildLabeledTextField(String label) {
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
  Widget __buildLabeledTextField(String label) {
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
  // nút thêm từ
  Widget add_word(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddWord()),
          );
        },
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(), // Hình tròn
          padding: EdgeInsets.all(20), // Kích thước nút
        ),
        child: Text(
          '+', // Dấu cộng
          style: TextStyle(
            fontSize: 30, // Kích thước chữ
            color: Colors.white, // Màu chữ
          ),
        ),
      ),
    );
  }
}

// Tạo âm thanh
  final double size;

  const AddSoundButton({Key? key, required this.size}) : super(key: key);

  @override
  _AddSoundButtonState createState() => _AddSoundButtonState();
}
class _AddSoundButtonState extends State<AddSoundButton> {

  final AudioPlayer _player = AudioPlayer();
  String? _filePath;
  String? _fileName;
  Duration? _duration;
  bool _isPlaying = false;

  Future<void> _pickAudioFile() async {
    final typeGroup = XTypeGroup(
      label: 'audio',
      extensions: ['mp3', 'wav', 'm4a', 'aac'],
    );

    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file != null) {
      try {
        await _player.stop(); // Dừng file cũ nếu có
        await _player.setFilePath(file.path);

        final duration = await _player.durationFuture;

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
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
    setState(() {
      _isPlaying = _player.playing;
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
              icon: Icon(Icons.close),
              onPressed: () async {
                await _player.stop();
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
  @override
  State<InputSection> createState() => _InputSectionState();
}
class _InputSectionState extends State<InputSection> {
  final List<Uint8List> _images = [];

  bool _isHovering = false;

  Future<void> _pickImage() async {
    final XFile? file = await openFile(
      acceptedTypeGroups: [XTypeGroup(label: 'images', extensions: ['jpg', 'png', 'jpeg'])],
    );
    if (file != null) {
      final Uint8List bytes = await file.readAsBytes();
      setState(() {
        _images.add(bytes);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    const double imageWidth = 120;
    const double imageHeight = 160;

    return Row(
      children: [
        SizedBox(width: 100),
        Expanded(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (int i = 0; i < _images.length; i++)
                Stack(
                  children: [
                    Container(
                      width: imageWidth,
                      height: imageHeight,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        color: Colors.grey.shade200,
                      ),
                      child: Image.memory(_images[i], fit: BoxFit.cover),
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
  }
}
// thẻ từ vựng
class VocabCard extends StatelessWidget {
  final String word;
  final String meaning1;
  final String audioUrl1;
  final String meaning2;
  final String audioUrl2;

  final AudioPlayer _player = AudioPlayer();

  VocabCard({
    required this.word,
    required this.meaning1,
    required this.audioUrl1,
    required this.meaning2,
    required this.audioUrl2,
  });

  void _play(String url) async {
    try {
      await _player.setUrl(url);
      _player.play();
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(word, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Row(
              children: [
                Expanded(child: Text(meaning1)),
                IconButton(icon: Icon(Icons.volume_up), onPressed: () => _play(audioUrl1)),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text(meaning2)),
                IconButton(icon: Icon(Icons.volume_up), onPressed: () => _play(audioUrl2)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
