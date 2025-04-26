import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:just_audio/just_audio.dart';

class AddWord extends StatefulWidget {
  const AddWord({super.key});

  @override
  _AddWordState createState() => _AddWordState();
}

class _AddWordState extends State<AddWord> {

  String? _selectedTuLoai;
  final List<String> _dsTuLoai = ['Danh từ', 'Động từ', 'Tính từ', 'Trạng từ',
    'Giới từ', 'Liên từ', 'Thán từ', 'Đại từ', 'Từ hạn định'];
  List<Widget> meaningBoxes = [];

  @override
  void initState() {
    super.initState();
    meaningBoxes.add(meaningBox());
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
        actions: [
          // IconButton ở bên trái
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, color: Colors.blue.shade700, size: 24),
              ),
              onPressed: () {},
            ),
          ),

          // Thêm Expanded để làm DICTIONARY nằm giữa
          Expanded(
            child: Center(
              child: Text(
                'DICTIONARY',
                softWrap: false,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),

          // Thêm phần tử ở bên phải
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
                SizedBox(width: 4),
                Text(
                  "$streakCount",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10),
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
                        //underline: SizedBox(), // Ẩn đường gạch dưới mặc định
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
                          AddSoundButton(),


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
                          AddSoundButton(),


                        ],
                      ),
                      SizedBox(height: 10, width: screenWidth),

                      ...meaningBoxes,
                      SizedBox(height: 5, width: screenWidth),

                      // xóa thêm nghĩa
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10), // cách viền trái
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
                              padding: const EdgeInsets.only(right: 10), // cách viền phải
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
  Widget meaningBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabeledTextField('Nghĩa'),
          SizedBox(height: 10),
          _buildLabeledTextField('Ví dụ 1'),
          SizedBox(height: 10),
          _buildLabeledTextField('Ví dụ 2'),
        ],
      ),
    );
  }
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

}

// Tạo âm thanh
class AddSoundButton extends StatefulWidget {
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

  String _shortenFileName(String name, [int maxLength = 20]) {
    if (name.length <= maxLength) return name;
    return name.substring(0, maxLength) + "...";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          if (_filePath != null) ...[
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 300,
            ),
             child: Text(
                "🎵 ${_shortenFileName(_fileName ?? "")}",
                overflow: TextOverflow.ellipsis,
              ),
          ),
            const SizedBox(width: 8),
            Text("🕒 ${_duration?.inSeconds ?? '...'}s"),
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
          ] else ...[
            ElevatedButton.icon(
              onPressed: _pickAudioFile,
              icon: Icon(Icons.upload_file),
              label: Text("Chọn file"),
            ),
          ],
        ],
      ),
    );
  }
}

