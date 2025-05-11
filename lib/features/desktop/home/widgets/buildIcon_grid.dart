import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:process_run/shell.dart';
import 'dart:async';
import 'package:eng_dictionary/features/desktop/translate/translate_screen.dart';
import 'package:eng_dictionary/features/desktop/my_word/screens/my_word.dart';
import 'package:eng_dictionary/features/desktop/flashcards/screens/flashcard_screen.dart';
import 'package:eng_dictionary/features/desktop/minigame/screens/minigame_screen.dart';

class BuildIconGrid extends StatefulWidget {

  final TextEditingController controller;
  const BuildIconGrid({super.key, required this.controller});

  @override
  State<BuildIconGrid> createState() => _BuildIconGrid();
}

class _BuildIconGrid extends State<BuildIconGrid> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {

    double space = 16;
    double width = MediaQuery.of(context).size.width / 2 + space;
    return  ConstrainedBox(
       constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.54,
                  ),
       child: LayoutBuilder(
        builder: (context, constraints) {
          double availableHeight = constraints.maxHeight; // Lấy chiều cao còn lại
          return Center(
            child: SizedBox(
              width: width,
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: space,
                mainAxisSpacing: space,
                childAspectRatio: (width-space) / (availableHeight-space).clamp(200, 9999), // Căn chỉnh tỷ lệ kích thước ô
                children: [
                  FeatureButton(
                    icon: Icons.translate,
                    label: 'Dịch văn bản',
                    color: Colors.blue.shade600,
                    height: (availableHeight-space)/2,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Translate()),
                      ).then((_) {
                        if (mounted) {
                          _controller.clear();
                      }
                      });
                    },
                  ),
                  FeatureButton(
                    icon: Icons.add_circle_outline,
                    label: 'Kho từ vựng',
                    color: Colors.purple.shade400,
                    height: (availableHeight-space)/2,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyWord()),
                      ).then((_) {
                        if (mounted) {
                          _controller.clear();
                        }
                      });
                    },
                  ),
                  FeatureButton(
                    icon: Icons.card_membership,
                    label: 'Flashcard',
                    color: Colors.teal.shade500,
                    height: (availableHeight-space)/2,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FlashcardScreen()));
                    },
                  ),
                  FeatureButton(
                    icon: Icons.games,
                    label: 'Minigame',
                    color: Colors.amber.shade700,
                    height: (availableHeight-space)/2,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MinigameScreen()));
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class FeatureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double height;
  final VoidCallback onTap;

  const FeatureButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        height: 50,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 35, color: color),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              softWrap: false, // Ngăn không cho chữ xuống dòng
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}