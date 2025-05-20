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
   return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [

        Text(
          label,
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
}
