import 'package:flutter/material.dart';

class AddWord extends StatefulWidget {
  const AddWord({super.key});

  @override
  _AddWordState createState() => _AddWordState();
}

class _AddWordState extends State<AddWord> {

  String? _selectedTuLoai;
  final List<String> _dsTuLoai = ['Danh từ', 'Động từ', 'Tính từ', 'Trạng từ'];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    int streakCount = 5; // Đợi dữ liệu từ database

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
        leadingWidth: 200,
        leading: Row(
          children: [
            BackButton(color: Colors.blue.shade50),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                'Kho từ vựng',
                softWrap: false,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade50,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Text(
                "$streakCount",
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
            ],
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle),
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
          child: SingleChildScrollView(
            child: Column(

              children: [
                SizedBox(height: 25, width: screenWidth),

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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
               child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Thêm từ',
                    hintStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue), // Viền xanh khi chưa focus
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0), // Viền xanh khi focus
                    ),
                  ),
                  maxLines: 1, // Không cho xuống dòng
                ),
            ),

                Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Từ loại: ',
                      style: TextStyle(fontSize: 16),
                    ),

                    SizedBox(width: 8),
                    // Nút chọn từ loại
                    DropdownButton<String>(
                      hint: Text("Chọn từ loại"),
                      value: _selectedTuLoai,
                      items: _dsTuLoai.map((loai) {
                        return DropdownMenuItem(
                          value: loai,
                          child: Text(loai),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTuLoai = value;
                        });
                      },
                    ),

                  ],
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
        icon: Icon(Icons.arrow_back, size: 20, color: Colors.black),
        onPressed: () {
          Navigator.pop(context); // Quay lại màn hình trước đó
        },
      ),
    );
  }
}