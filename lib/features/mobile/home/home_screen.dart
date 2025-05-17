import 'package:eng_dictionary/features/mobile/my_word/screens/my_word.dart';
import 'package:flutter/material.dart';
import 'package:eng_dictionary/features/common/widgets/streak_count.dart';
import 'package:eng_dictionary/features/mobile/settings/widgets/setting_button.dart';
import 'package:eng_dictionary/features/mobile/home/search.dart';
import 'package:eng_dictionary/features/common/widgets/logo_big.dart';
import 'package:eng_dictionary/core/services/auth_service.dart';
import 'package:eng_dictionary/features/mobile/settings/screens/setting_screen.dart';
import 'package:eng_dictionary/features/mobile/translate/translate_screen.dart';
import 'package:eng_dictionary/features/mobile/flashcards/screens/flashcard_screen.dart';
import 'package:eng_dictionary/features/mobile/minigame/screens/minigame_screen.dart';
class HomeScreenPhone extends StatefulWidget {
  const HomeScreenPhone({super.key});

  @override
  State<HomeScreenPhone> createState() => _HomeScreenPhoneState();
}

class _HomeScreenPhoneState extends State<HomeScreenPhone> {
  TextEditingController _controller = TextEditingController();
  int streakCount = 0;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final email = await AuthService.getUserEmail();
    setState(() {
      userEmail = email;
      streakCount = 5; // TODO: Thay bằng logic lấy streak từ server hoặc local
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
        leading: Container(),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.orange.shade600,
                    size: 28,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "$streakCount",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: Colors.blue.shade700, size: 20),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SettingsPhone(userEmail: userEmail ?? ''),
                ),
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
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
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 30),
                SearchPhone(controller: _controller),
                const SizedBox(height: 40),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      FeatureButton(
                        icon: Icons.translate,
                        label: 'Dịch văn bản',
                        color: Colors.blue.shade600,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Translate(),
                            ),
                          ).then((_) {
                            _controller.clear();
                          });
                        },
                      ),
                      FeatureButton(
                        icon: Icons.add_circle_outline,
                        label: 'Kho từ vựng',
                        color: Colors.purple.shade400,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyWord(),
                            ),
                          ).then((_) {
                            _controller.clear();
                          });
                        },
                      ),
                      FeatureButton(
                        icon: Icons.card_membership,
                        label: 'Flashcard',
                        color: Colors.teal.shade500,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FlashcardScreen(),
                            ),
                          ).then((_) {
                            _controller.clear();
                          });
                        },
                      ),
                      FeatureButton(
                        icon: Icons.games,
                        label: 'Minigame',
                        color: Colors.amber.shade700,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MinigameScreen(),
                            ),
                          ).then((_) {
                            _controller.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FeatureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const FeatureButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 16),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
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
