import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:just_audio/just_audio.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../back_end/api_service.dart';
import '../database_SQLite/database_helper.dart';

class AddWord extends StatefulWidget {
  const AddWord({super.key});

  @override
  _AddWordState createState() => _AddWordState();
}

class _AddWordState extends State<AddWord> {
  String? _selectedTuLoai;
  final List<String> _dsTuLoai = [
    'Danh từ',
    'Động từ',
    'Tính từ',
    'Trạng từ',
    'Giới từ',
    'Liên từ',
    'Thán từ',
    'Đại từ',
    'Từ hạn định',
  ];
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _definitionController = TextEditingController();
  final TextEditingController _example1Controller = TextEditingController();
  final TextEditingController _example2Controller = TextEditingController();
  final TextEditingController _synonymsController = TextEditingController();
  final TextEditingController _antonymsController = TextEditingController();
  final TextEditingController _familyController = TextEditingController();
  final TextEditingController _phrasesController = TextEditingController();
  String? _usAudioPath;
  String? _ukAudioPath;
  String? _usAudioName;
  String? _ukAudioName;
  bool _isLoading = false;
  String? _errorMessage;
  int streakCount = 0;

  Future<void> _fetchStreakCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      streakCount = prefs.getInt('streak_count') ?? 5;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchStreakCount();
  }

  @override
  void dispose() {
    _wordController.dispose();
    _definitionController.dispose();
    _example1Controller.dispose();
    _example2Controller.dispose();
    _synonymsController.dispose();
    _antonymsController.dispose();
    _familyController.dispose();
    _phrasesController.dispose();
    super.dispose();
  }

  Future<void> _saveWord() async {
    if (_wordController.text.isEmpty || _selectedTuLoai == null) {
      setState(() {
        _errorMessage = 'Vui lòng nhập từ vựng và chọn từ loại';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final uuid = Uuid();
      final now = DateTime.now();
      final wordId = uuid.v4();
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email') ?? 'unknown_user@example.com';

      final word = Word(
        wordId: wordId,
        userEmail: userEmail,
        word: _wordController.text,
        partOfSpeech: _selectedTuLoai!,
        usIpa: _usAudioName,
        ukIpa: _ukAudioName,
        definition: _definitionController.text,
        examples: [
          if (_example1Controller.text.isNotEmpty) _example1Controller.text,
          if (_example2Controller.text.isNotEmpty) _example2Controller.text,
        ].where((example) => example.isNotEmpty).toList(),
        synonyms: _synonymsController.text.isNotEmpty
            ? _synonymsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .map((s) => Synonym(synonymId: uuid.v4(), synonymWordId: s))
            .toList()
            : [],
        antonyms: _antonymsController.text.isNotEmpty
            ? _antonymsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .map((s) => Antonym(antonymId: uuid.v4(), antonymWordId: s))
            .toList()
            : [],
        family: _familyController.text.isNotEmpty
            ? _familyController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .map((s) => FamilyWord(familyId: uuid.v4(), familyWord: s))
            .toList()
            : [],
        phrases: _phrasesController.text.isNotEmpty
            ? _phrasesController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .map((s) => Phrase(phraseId: uuid.v4(), phrase: s))
            .toList()
            : [],
        media: [
          if (_usAudioPath != null)
            Media(
              mediaId: uuid.v4(),
              type: 'usAudio',
              filePath: _usAudioPath!,
            ),
          if (_ukAudioPath != null)
            Media(
              mediaId: uuid.v4(),
              type: 'ukAudio',
              filePath: _ukAudioPath!,
            ),
        ],
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      // Lưu vào SQLite
      await DatabaseHelper.instance.insertWord(word);

      // Đồng bộ lên server
      final payload = {
        'change': [
          {
            'word_id': word.wordId,
            'word': word.word,
            'part_of_speech': word.partOfSpeech,
            'us_ipa': word.usIpa ?? '',
            'uk_ipa': word.ukIpa ?? '',
            'definition': word.definition,
            'example': word.examples,
            'synonyms': word.synonyms.map((s) => s.synonymWordId).toList(),
            'antonyms': word.antonyms.map((s) => s.antonymWordId).toList(),
            'family': word.family.map((f) => f.familyWord).toList(),
            'phrases': word.phrases.map((p) => p.phrase).toList(),
            'created_at': word.createdAt.toIso8601String(),
            'updated_at': word.updatedAt.toIso8601String(),
            'us_audio': _usAudioPath != null,
            'uk_audio': _ukAudioPath != null,
            'image': false,
            'is_deleted': word.isDeleted ? 1 : 0,
          }
        ]
      };

      final files = <String, File>{};
      if (_usAudioPath != null) {
        files['media[usAudio][${word.wordId}]'] = File(_usAudioPath!);
      }
      if (_ukAudioPath != null) {
        files['media[ukAudio][${word.wordId}]'] = File(_ukAudioPath!);
      }

      final response = await ApiService.postWithFiles(
        'sync/uploadWords',
        {'payload': jsonEncode(payload)},
        files,
      );

      if (response['success'] == true) {
        await DatabaseHelper.instance.markWordAsSynced(word.wordId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thêm từ vựng thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Lỗi đồng bộ từ vựng';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi đồng bộ từ vựng: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool _isHovering = false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
              ),
              onPressed: () {},
            ),
          ),
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
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                  size: 28,
                ),
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
                      TextField(
                        controller: _wordController,
                        decoration: InputDecoration(
                          hintText: 'Từ vựng',
                          hintStyle: TextStyle(color: Colors.blue.shade300),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 2.0),
                          ),
                        ),
                        maxLines: 1,
                      ),
                      SizedBox(height: 10, width: screenWidth),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Từ loại: ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          DropdownButton<String>(
                            hint: Text(
                              "Chọn từ loại",
                              style: TextStyle(fontSize: 16, color: Colors.blue.shade900),
                            ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Phiên âm US: ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          AddSoundButton(
                            onFileSelected: (path, name) {
                              setState(() {
                                _usAudioPath = path;
                                _usAudioName = name;
                              });
                            },
                            onFileRemoved: () {
                              setState(() {
                                _usAudioPath = null;
                                _usAudioName = null;
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
                            'Phiên âm UK: ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          AddSoundButton(
                            onFileSelected: (path, name) {
                              setState(() {
                                _ukAudioPath = path;
                                _ukAudioName = name;
                              });
                            },
                            onFileRemoved: () {
                              setState(() {
                                _ukAudioPath = null;
                                _ukAudioName = null;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10, width: screenWidth),
                      _buildLabeledTextField('Định nghĩa', _definitionController),
                      SizedBox(height: 10, width: screenWidth),
                      _buildLabeledTextField('Ví dụ 1', _example1Controller),
                      SizedBox(height: 10, width: screenWidth),
                      _buildLabeledTextField('Ví dụ 2', _example2Controller),
                      SizedBox(height: 10, width: screenWidth),
                      _buildLabeledTextField('Từ đồng nghĩa', _synonymsController),
                      SizedBox(height: 10, width: screenWidth),
                      _buildLabeledTextField('Từ trái nghĩa', _antonymsController),
                      SizedBox(height: 10, width: screenWidth),
                      _buildLabeledTextField('Họ từ vựng', _familyController),
                      SizedBox(height: 10, width: screenWidth),
                      _buildLabeledTextField('Cụm từ', _phrasesController),
                      SizedBox(height: 10, width: screenWidth),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveWord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Lưu từ vựng'),
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

  Widget _buildLabeledTextField(String label, TextEditingController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue.shade900,
              fontWeight: FontWeight.bold,
            ),
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
        ),
      ],
    );
  }
}

class AddSoundButton extends StatefulWidget {
  final Function(String, String) onFileSelected;
  final VoidCallback onFileRemoved;

  const AddSoundButton({
    required this.onFileSelected,
    required this.onFileRemoved,
    super.key,
  });

  @override
  _AddSoundButtonState createState() => _AddSoundButtonState();
}

class _AddSoundButtonState extends State<AddSoundButton> {
  late final AudioPlayer _player = AudioPlayer();
  String? _filePath;
  String? _fileName;
  Duration? _duration;
  bool _isPlaying = false;

  Future<void> _pickAudioFile() async {
    XTypeGroup typeGroup;

    if (Platform.isAndroid) {
      typeGroup = XTypeGroup(
        label: 'audio',
        extensions: ['mp3', 'wav', 'm4a', 'aac'],
      );
    } else if (Platform.isIOS) {
      typeGroup = XTypeGroup(
        label: 'audio',
        uniformTypeIdentifiers: ['public.audio'],
      );
    } else {
      typeGroup = XTypeGroup(
        label: 'audio',
        extensions: ['mp3', 'wav', 'm4a', 'aac'],
      );
    }

    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file != null) {
      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File quá lớn, vui lòng chọn file dưới 5MB'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!['mp3', 'wav', 'm4a', 'aac'].contains(file.name.split('.').last.toLowerCase())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Định dạng file không hỗ trợ, chỉ chấp nhận mp3, wav, m4a, aac'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        await _player.stop();
        await _player.setFilePath(file.path);

        final duration = await _player.durationFuture;

        setState(() {
          _filePath = file.path;
          _fileName = file.name;
          _duration = duration;
          _isPlaying = false;
        });

        widget.onFileSelected(file.path, file.name);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã chọn file âm thanh: ${file.name} thành công',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blue,
          ),
        );
      } catch (e) {
        print('Lỗi khi tải file: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Không tải file âm thanh: $e',
              style: TextStyle(color: Colors.white),
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
                widget.onFileRemoved();
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