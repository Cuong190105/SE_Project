import 'package:flutter/material.dart';

class Translate extends StatelessWidget {
  const Translate({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
        body: Container(
        margin: EdgeInsets.all(10), // Tạo khoảng cách với mép màn hình
    decoration: BoxDecoration(
    color: Colors.white, // Màu nền bên trong viền
    border: Border.all(
    color: Colors.black, // Màu viền
    width: 2, // Độ dày viền
    ),
    borderRadius: BorderRadius.circular(20), // Bo góc viền
    ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            space(20),
            Row(
              children: [
                DICTIONARY(),
                Positioned(
                  top: 99, // Cố định tiêu đề ở góc trái trên
                  child: search(screenWidth * 0.3), // Thanh tìm kiếm ở trung tâm
                ),
              ],
            ),

            space(10),

            // Nút back phía dưới
            buttonBack(context),
          ],
        ),
       ),
        ),
    );
  }

  // tạo khoảng cách
  Widget space(double height) {
    return SizedBox(height: height);
  }

  // Nút quay lại
  Widget buttonBack(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft, // Canh về góc trái trên
      child: IconButton(
        icon: Icon(Icons.arrow_back, size: 30, color: Colors.black),
        onPressed: () {
          Navigator.pop(context); // Quay lại màn hình trước đó
        },
      ),
    );
  }

  // tạo tiêu đề
  Widget DICTIONARY() {
    return Align(
      alignment: Alignment.topLeft, // Đưa chữ lên góc trái trên
      child: Padding(
        padding: const EdgeInsets.all(10), // Tạo khoảng cách với viền
        child: Text(
          "DICTIONARY",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          overflow: TextOverflow.clip,
          softWrap: false,
        ),
      ),
    );
  }
  // tạo thanh tìm kiếm
  Widget search(double width) {
    return  SizedBox(
      width: width, // Chiều rộng 50% màn hình

      child: Container(
        color: Colors.white, // Đặt màu nền xám
        child: TextField(
          decoration: InputDecoration(
            hintText: "Nhập từ bạn muốn tìm kiếm",
            hintStyle: TextStyle(
                fontSize: 15,
                //height: screenHeight * 0.08, // Chiều cao 10% màn hình
                color: Colors.grey[600]), // Màu chữ gợi ý
            filled: true,
            fillColor: Colors.grey[300], // Màu nền xám nhạt
            prefixIcon: IconButton(
              icon: Icon(Icons.search, color: Colors.grey[600]),
              onPressed: () {
                print("Tìm kiếm..."); // xử lý sự kiện
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30), // Bo tròn
              borderSide: BorderSide.none, // Ẩn viền
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20), // Khoảng cách nội dung
          ),
        ),
      ),
    );
  }

}