import 'package:flutter/material.dart';
import 'dart:math';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: Colors.blue.shade700, size: 20),
            ),
            onPressed: () {},
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
                    softWrap: false, // Ngăn không cho chữ xuống dòng
                    'DICTIONARY',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: screenWidth / 2,
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
                    ),
                  ),
                  const SizedBox(height: 40),
                  buildIconGrid(context, screenWidth/2+16)
                ],
              ),
            ),
          ),
        ),
    );
  }
}
// tạo lưới ô
Widget buildIconGrid(BuildContext context, double width) {

  double space = 16;

  return Expanded(
    child: LayoutBuilder(
      builder: (context, constraints) {
        double availableHeight = constraints.maxHeight; // Lấy chiều cao còn lại
        return Center(
          child: SizedBox(
            width: width,
            height: availableHeight,
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: space,
              mainAxisSpacing: space,
              childAspectRatio: (width-space) / (availableHeight-space).clamp(145, 9999), // Căn chỉnh tỷ lệ kích thước ô
              children: [
                FeatureButton(
                  icon: Icons.translate,
                  label: 'Dịch văn bản',
                  color: Colors.blue.shade600,
                  height: (availableHeight-space)/2,
                  onTap: () {

                  },
                ),
                FeatureButton(
                  icon: Icons.add_circle_outline,
                  label: 'Thêm từ',
                  color: Colors.purple.shade400,
                  height: (availableHeight-space)/2,
                  onTap: () {

                  },
                ),
                FeatureButton(
                  icon: Icons.card_membership,
                  label: 'Flashcard',
                  color: Colors.teal.shade500,
                  height: (availableHeight-space)/2,
                  onTap: () {

                  },
                ),
                FeatureButton(
                  icon: Icons.games,
                  label: 'Minigame',
                  color: Colors.amber.shade700,
                  height: (availableHeight-space)/2,
                  onTap: () {

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
    double space = 16;
    double width = (MediaQuery.of(context).size.width/2-space)/2;

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
            Icon(icon, size: (min(width,height)*0.19).clamp(15, 200), color: color),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              softWrap: false, // Ngăn không cho chữ xuống dòng
              style: TextStyle(
                fontSize: (min(width,height)*0.19).clamp(10, 200),
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
