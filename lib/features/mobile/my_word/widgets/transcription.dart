import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'sound_button.dart';

class Transcription extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueNotifier<AudioPlayer> audioPlayer;

  const Transcription({
    super.key,
    required this.label,
    required this.controller,
    required this.audioPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
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
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: AddSoundButton(
            size: 800,
            audioPlayer: audioPlayer,
          ),
        ),
      ],
    );
  }
}
