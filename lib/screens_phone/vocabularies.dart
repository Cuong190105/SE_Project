import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'add_word.dart';
import 'home_phone.dart';

class Vocabularies extends StatefulWidget {
  const Vocabularies({super.key});

  @override
  _Vocabularies createState() => _Vocabularies();
}

class _Vocabularies extends State<Vocabularies> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int streakCount = 5; // Đợi dữ liệu từ database

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
        leading: Container(),
        title: Text(
          'DICTIONARY',
          style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2),
        ),
        actions: [
          Row(
            children: [
              Text(
                "$streakCount",
                style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const Icon(Icons.local_fire_department,
                  color: Colors.orange, size: 32),
            ],
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: [
                      // Phần bên trái: nút quay lại + tiêu đề
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              borderRadius: BorderRadius.circular(30),
                              splashColor: Colors.blue.withOpacity(0.2),
                              highlightColor: Colors.blue.withOpacity(0.1),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    buttonBack(context),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Kho từ vựng',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Spacer đẩy nút + sang phải
                      Spacer(),
                      add_button(context),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Column(
                    children: [],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Nút quay lại
  Widget buttonBack(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft, // Canh về góc trái trên
      child: IconButton(
        icon: Icon(Icons.arrow_back, size: 30, color: Colors.blue.shade700),
        onPressed: () {
          Navigator.pop(context); // Quay lại màn hình trước đó
        },

        hoverColor:
            Colors.grey.shade300.withOpacity(0), // Màu nền khi di chuột vào
      ),
    );
  }

  // nút thêm từ
  Widget add_button(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddWord()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade500, // Nền xanh dương
        shape: CircleBorder(), // Hình tròn
        padding: EdgeInsets.all(15), // Kích thước nút
        elevation: 1, // Đổ bóng nhẹ
      ),
      child: Icon(
        Icons.add, // Icon dấu +
        color: Colors.white, // Màu trắng
        size: 32, // Kích thước icon
      ),
    );
  }
}
