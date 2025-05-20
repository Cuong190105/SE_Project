import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:eng_dictionary/features/mobile/my_word/widgets/input_image.dart';
import 'package:eng_dictionary/features/mobile/my_word/widgets/sound_button.dart';
import 'package:eng_dictionary/features/mobile/my_word/widgets/transcription.dart';
import 'package:eng_dictionary/features/mobile/my_word/widgets/example.dart';

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
    
    return Container(
      
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade50,
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown chọn từ loại
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Từ loại: ',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12), // khoảng cách giữa chữ và dropdown
              Expanded(
                child: ValueListenableBuilder<String>(
                  valueListenable: selectedType,
                  builder: (context, value, _) {
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: "Chọn từ loại",
                        hintStyle: TextStyle(
                            fontSize: 16, color: Colors.blue.shade900),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                      ),
                      isExpanded: true,
                      value: selectedType.value.isEmpty
                          ? null
                          : selectedType.value,
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
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Phiên âm UK
          Transcription(
            label: 'Phiên âm UK:',
            audioPlayer: audioPlayers[0],
            controller: phoneticUkController,
          ),
          const SizedBox(height: 8),

          // Phiên âm US
          Transcription(
            label: 'Phiên âm US:',
            audioPlayer: audioPlayers[1],
            controller: phoneticUsController,
          ),
          const SizedBox(height: 8),

          // Nghĩa + nút âm thanh
          Row(
            children: [
              Expanded(child: Example(label: 'Nghĩa', controller: meaningController)),
              const SizedBox(width: 8),
              //AddSoundButton(size: 900, audioPlayer: audioPlayers[2]),
            ],
          ),
          const SizedBox(height: 8),

          // Ví dụ 1 & 2
          Example(label: 'Ví dụ 1', controller: example1Controller),
          const SizedBox(height: 8),
          Example(label: 'Ví dụ 2', controller: example2Controller),
          const SizedBox(height: 8),

          Center(child: InputImage(images: imageByte)),
        ],
      ),
    );
  }
}
