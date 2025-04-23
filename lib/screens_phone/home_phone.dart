import 'package:eng_dictionary/screens_phone/authentic_phone/register_screen_phone.dart';
import 'package:eng_dictionary/screens_phone/flashcard_screen.dart';
import 'package:flutter/material.dart';
import 'translate.dart';
import 'add_word.dart';

class HomeScreenPhone extends StatelessWidget {
  const HomeScreenPhone({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    int streakCount = 5; // đợi data base
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
           child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(

                  children: [

                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade100,
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: IconButton(
                            icon: Icon(Icons.search, color: Colors.blue.shade700),
                            onPressed: () {},
                          ),
                          hintText: 'Nhập từ cần tìm kiếm',
                          hintStyle: TextStyle(color: Colors.blue.shade300),
                          border: InputBorder.none,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),

                    buildIconGrid(context, screenWidth),

                  ],
                ),
            ),
        ),
      ),


    );
  }
}
// tạo lưới ô
Widget buildIconGrid(BuildContext context, double screenWidth) {

  double space = 16;

  return Expanded(
    child: LayoutBuilder(
      builder: (context, constraints) {
        double availableHeight = constraints.maxHeight; // Lấy chiều cao còn lại
        return Center(
          child: SizedBox(
            width: screenWidth,
            child: ListView(
              padding: EdgeInsets.all(10),
              children: [
                FeatureButton(
                  icon: Icons.translate,
                  label: 'Dịch văn bản',
                  color: Colors.blue.shade600,
                  height: (availableHeight - space * 4) / 4-1,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Translate()),
                    );
                  },
                ),
                SizedBox(height: space),
                FeatureButton(
                  icon: Icons.add_circle_outline,
                  label: 'Kho từ vựng',
                  color: Colors.purple.shade400,
                  height: (availableHeight - space * 4) / 4-1,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddWord()),
                    );
                  },
                ),
                SizedBox(height: space),
                FeatureButton(
                  icon: Icons.card_membership,
                  label: 'Flashcard',
                  color: Colors.teal.shade500,
                  height: (availableHeight - space * 4) / 4-1,
                  onTap: () {},
                ),
                SizedBox(height: space),
                FeatureButton(
                  icon: Icons.games,
                  label: 'Minigame',
                  color: Colors.amber.shade700,
                  height: (availableHeight - space * 4) / 4-1,
                  onTap: () {},
                ),
              ],
            ),
          ),
        );

      },
    ),
  );
}
// lớp ô vuông
class FeatureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final double height; // Thêm dòng này

  const FeatureButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.height, // Thêm dòng này
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: height, // Sử dụng tham số height ở đây
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 35, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            softWrap: false,
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
