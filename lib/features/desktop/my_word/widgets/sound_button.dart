import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:just_audio/just_audio.dart';

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
  @override
  void initState() {
    super.initState();
    _player = widget.audioPlayer;

    // Lắng nghe sự thay đổi duration
    _player.value.durationStream.listen((duration) {
      if (duration != null) {
        setState(() {
          _duration = duration;
        });
      }
    });

    // Lắng nghe trạng thái playing
    _player.value.playingStream.listen((playing) {
      setState(() {
        _isPlaying = playing;
      });
    });

    // Lắng nghe trạng thái hoàn thành
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      //color: Colors.amber.withOpacity(0.3),
      child: Row(
        children: [
          if (_filePath != null || _player.value.duration != null) ...[
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