import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'translate.dart';
import 'vocabularies.dart';
import 'vocabulary.dart';
import 'package:eng_dictionary/screens_desktop/authentic_desktop/register_screen.dart';
import 'settings.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'search.dart';
import 'package:eng_dictionary/screens_desktop/flashcard_screen.dart';
import 'package:eng_dictionary/screens_desktop/minigame_screen_phone.dart';

class HomeScreenDesktop extends StatefulWidget {
  const HomeScreenDesktop({super.key});

  @override
  _HomeScreenDesktopState createState() => _HomeScreenDesktopState();
}
class _HomeScreenDesktopState extends State<HomeScreenDesktop> {

  TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int streakCount = 5; // Đợi database
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 1),
            child: Row(
              children: [
                Text(
                  "$streakCount",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
              ],
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: Colors.blue.shade700, size: 20),
            ),
            onPressed: () async {
              // Lấy userEmail từ SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              final userEmail = prefs.getString('user_email') ?? 'default@example.com';
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPhone(userEmail: userEmail)),
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
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade100,
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.book,
                    size: 50,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'DICTIONARY',
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 30),
                Search(controller: _controller),
                const SizedBox(height: 24),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.54, // Giới hạn chiều cao
                  ),
                  child: buildIconGrid(context, screenWidth / 2 + 16),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // tạo lưới ô
  Widget buildIconGrid(BuildContext context, double width) {

    double space = 16;

    return
      LayoutBuilder(
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
                        _controller.clear();
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
                        MaterialPageRoute(builder: (context) => const Vocabularies()),
                      ).then((_) {
                        _controller.clear();
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
      );
  }
}

// lớp ô vuông
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