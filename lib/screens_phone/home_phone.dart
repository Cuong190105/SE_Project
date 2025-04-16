// import 'package:flutter/material.dart';
// import 'translate.dart';
// import 'add_word.dart';

// class HomeScreenPhone extends StatelessWidget {
//   const HomeScreenPhone({super.key});

//   @override
// Widget build(BuildContext context) {
// double screenWidth = MediaQuery.of(context).size.width;
// double screenHeight = MediaQuery.of(context).size.height;
// int streakCount = 5; // đợi data base
//   return Scaffold(

//     appBar: AppBar(
//       backgroundColor: Colors.blue.shade300,
//       elevation: 0,
//       actions: [
//         // IconButton ở bên trái
//         Padding(
//           padding: const EdgeInsets.only(left: 8),
//           child: IconButton(
//             icon: Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade100,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(Icons.person, color: Colors.blue.shade700, size: 24),
//             ),
//             onPressed: () {},
//           ),
//         ),

//           // Thêm Expanded để làm DICTIONARY nằm giữa
//           Expanded(
//             child: Center(
//               child: Text(
//                 'DICTIONARY',
//                 softWrap: false,
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blue.shade800,
//                   letterSpacing: 2,
//                 ),
//               ),
//             ),
//           ),

//           // Thêm phần tử ở bên phải
//           Padding(
//             padding: const EdgeInsets.only(right: 8),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
//                 SizedBox(width: 4),
//                 Text(
//                   "$streakCount",
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),

//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.blue.shade50, Colors.white],
//             stops: const [0.3, 1.0],
//           ),
//         ),
//         child: SafeArea(
//            child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                 child: Column(

//                   children: [

//                     const SizedBox(height: 10),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(30),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.blue.shade100,
//                             blurRadius: 5,
//                             spreadRadius: 1,
//                           ),
//                         ],
//                       ),
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: TextField(
//                         decoration: InputDecoration(
//                           prefixIcon: IconButton(
//                             icon: Icon(Icons.search, color: Colors.blue.shade700),
//                             onPressed: () {},
//                           ),
//                           hintText: 'Nhập từ cần tìm kiếm',
//                           hintStyle: TextStyle(color: Colors.blue.shade300),
//                           border: InputBorder.none,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                     const SizedBox(height: 10),

//                     buildIconGrid(context, screenWidth),

//                   ],
//                 ),
//             ),
//         ),
//       ),

//     );
//   }
// }
// // tạo lưới ô
// Widget buildIconGrid(BuildContext context, double screenWidth) {

//   double space = 16;

//   return Expanded(
//     child: LayoutBuilder(
//       builder: (context, constraints) {
//         double availableHeight = constraints.maxHeight; // Lấy chiều cao còn lại
//         return Center(
//           child: SizedBox(
//             width: screenWidth,
//             child: ListView(
//               padding: EdgeInsets.all(10),
//               children: [
//                 FeatureButton(
//                   icon: Icons.translate,
//                   label: 'Dịch văn bản',
//                   color: Colors.blue.shade600,
//                   height: (availableHeight - space * 4) / 4-1,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const Translate()),
//                     );
//                   },
//                 ),
//                 SizedBox(height: space),
//                 FeatureButton(
//                   icon: Icons.add_circle_outline,
//                   label: 'Kho từ vựng',
//                   color: Colors.purple.shade400,
//                   height: (availableHeight - space * 4) / 4-1,
//   onTap: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const AddWord()),
//     );
//   },
// ),
//                 SizedBox(height: space),
//                 FeatureButton(
//                   icon: Icons.card_membership,
//                   label: 'Flashcard',
//                   color: Colors.teal.shade500,
//                   height: (availableHeight - space * 4) / 4-1,
//                   onTap: () {},
//                 ),
//                 SizedBox(height: space),
//                 FeatureButton(
//                   icon: Icons.games,
//                   label: 'Minigame',
//                   color: Colors.amber.shade700,
//                   height: (availableHeight - space * 4) / 4-1,
//                   onTap: () {},
//                 ),
//               ],
//             ),
//           ),
//         );

//       },
//     ),
//   );
// }
// // lớp ô vuông
// class FeatureButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final double height;
//   final VoidCallback onTap;

//   const FeatureButton({
//     super.key,
//     required this.icon,
//     required this.label,
//     required this.color,
//     required this.height,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {

//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         height: height,
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 35, color: color),
//           const SizedBox(width: 5),
//           Text(
//             label,
//             textAlign: TextAlign.center,
//             softWrap: false,
//             style: TextStyle(
//               fontSize: 35,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//         ],
//       ),

//     ),
//     );
//   }
// }
import 'package:eng_dictionary/screens_phone/authentic_phone/register_screen.dart';
import 'package:flutter/material.dart';
import 'translate.dart';
import 'add_word.dart';

class HomeScreenPhone extends StatelessWidget {
  const HomeScreenPhone({super.key});

  @override
  Widget build(BuildContext context) {
    int streakCount = 5;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: Colors.blue.shade700, size: 20),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
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
                // App logo and name
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

                // Search bar
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
                      icon: Icon(Icons.search, color: Colors.blue.shade700),
                      hintText: 'Nhập từ cần tìm kiếm',
                      hintStyle: TextStyle(color: Colors.blue.shade300),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Feature buttons grid
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
                          );
                        },
                      ),
                      FeatureButton(
                        icon: Icons.add_circle_outline,
                        label: 'Thêm từ',
                        color: Colors.purple.shade400,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddWord(),
                            ),
                          );
                        },
                      ),
                      FeatureButton(
                        icon: Icons.card_membership,
                        label: 'Flashcard',
                        color: Colors.teal.shade500,
                        onTap: () {
                          Navigator.pushNamed(context, '/flashcard');
                        },
                      ),
                      FeatureButton(
                        icon: Icons.games,
                        label: 'Minigame',
                        color: Colors.amber.shade700,
                        onTap: () {
                          Navigator.pushNamed(context, '/minigame');
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
            const SizedBox(height: 8),
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
