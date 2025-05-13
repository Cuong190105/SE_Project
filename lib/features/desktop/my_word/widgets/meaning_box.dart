import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:eng_dictionary/features/desktop/my_word/widgets/input_image.dart';
import 'package:eng_dictionary/features/desktop/my_word/widgets/sound_button.dart';
import 'package:eng_dictionary/features/desktop/my_word/widgets/transcription.dart';
import 'package:eng_dictionary/features/desktop/my_word/widgets/example.dart';

class MeaningBox extends StatelessWidget {
  final ValueNotifier<String> selectedType;
  final TextEditingController meaningController;
  final TextEditingController example1Controller;
  final TextEditingController example2Controller;
  final TextEditingController phoneticUkController;
  final TextEditingController phoneticUsController;
  final List<ValueNotifier<AudioPlayer>> audioPlayers;
  final ValueNotifier<List<Uint8List>> imageByte;

  const MeaningBox({
    super.key,
    required this.selectedType,
    required this.meaningController,
    required this.example1Controller,
    required this.example2Controller,
    required this.phoneticUkController,
    required this.phoneticUsController,
    required this.audioPlayers,
    required this.imageByte,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> dsTuLoai = ['Danh từ', 'Động từ', 'Tính từ', 'Trạng từ',
      'Giới từ', 'Liên từ', 'Thán từ', 'Đại từ', 'Từ hạn định'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown chọn từ loại
          ValueListenableBuilder<String>(
            valueListenable: selectedType,
            builder: (context, value, _) {
              return DropdownButton<String>(
                hint: Text("Chọn từ loại", style: TextStyle(fontSize: 16, color: Colors.blue.shade900)),
                value: value.isEmpty ? null : value,
                items: dsTuLoai.map((loai) {
                  return DropdownMenuItem(
                    value: loai,
                    child: Text(loai),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) selectedType.value = value;
                },
              );
            },
          ),
          const SizedBox(height: 10),

          // Phiên âm UK
          Transcription(
            label: 'Phiên âm UK:',
            audioPlayer: audioPlayers[0],
            controller: phoneticUkController,
          ),
          const SizedBox(height: 10),

          // Phiên âm US
          Transcription(
            label: 'Phiên âm US:',
            audioPlayer: audioPlayers[1],
            controller: phoneticUsController,
          ),
          const SizedBox(height: 10),

          // Nghĩa + nút âm thanh
          Row(
            children: [
              Expanded(child: Example(label: 'Nghĩa', controller: meaningController)),
              const SizedBox(width: 8),
              //AddSoundButton(size: 900, audioPlayer: audioPlayers[2]),
            ],
          ),
          const SizedBox(height: 10),

          // Ví dụ 1 & 2
          Example(label: 'Ví dụ 1', controller: example1Controller),
          const SizedBox(height: 10),
          Example(label: 'Ví dụ 2', controller: example2Controller),
          const SizedBox(height: 10),

          Center(child: InputImage(images: imageByte)),
        ],
      ),
    );
  }
}