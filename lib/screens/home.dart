import 'package:flutter/material.dart';
import 'translate.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              space(50),
              DICTIONARY(), // tiêu đề kích thước 4% so với chiều dài
              space(50),
              search(screenWidth * 0.5 + 40), // thanh tìm kiếm
              space(50),
              buildIconGrid(context, screenWidth * 0.25, screenHeight * 0.25),
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

  // tạo tiêu đề
  Widget DICTIONARY() {
    return Center(
      child: Text(
        "DICTIONARY",
        style: TextStyle(
          fontSize: 40, // Cỡ chữ = 4% chiều rộng màn hình
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        overflow: TextOverflow.clip, // Giới hạn hiển thị trong một dòng
        softWrap: false, // Ngăn không cho chữ xuống dòng
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

  // Hàm tạo lưới 4 ô vuông
  Widget buildIconGrid(BuildContext context, double width, double height) {
    double minHeight = 90; // Giới hạn chiều cao tối thiểu
    double maxHeight = 200; // Giới hạn chiều cao tối đa
    double minHeightBox = minHeight*2+110;
    double maxHeightBox = maxHeight*2+110;
    return SizedBox(
      width: width*2+40,
      height: (height*2+110).clamp(minHeightBox,maxHeightBox),
    child:   Padding(
      padding: EdgeInsets.zero,
      child: GridView.count(
        crossAxisCount: 2, // 2 cột
        crossAxisSpacing: 40, // Khoảng cách ngang
        mainAxisSpacing: 30, // Khoảng cách dọc
        childAspectRatio: width/height.clamp(minHeight, maxHeight), // Tỷ lệ chiều rộng / chiều cao = 1 (hình vuông)
        children: [

          buildSquareItem(Icons.translate, "Dịch văn bản", context,() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Translate()),
            );},width, height),

          buildSquareItem(Icons.note_add , "Thêm từ", context,() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Translate()),
            );},width, height),

          buildSquareItem(Icons.style , "Flashcard", context,() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Translate()),
            );},width, height),

          buildSquareItem(Icons.games, "Minigame", context,() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Translate()),
            );},width, height),

        ],
      ),
      ),
    );
  }

  // Hàm tạo ô vuông có icon + chữ
  Widget buildSquareItem(IconData icon, String label, BuildContext context,
      VoidCallback onTap, double width, double height) {
    return GestureDetector(
      onTap: onTap, // Gọi hàm khi nhấn vào
      child: SizedBox(
        width: width,
        height: height,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300], // Màu nền xám
            borderRadius: BorderRadius.circular(10), // Bo góc nhẹ
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Căn giữa dọc
            children: [
              Icon(icon, size: (width * 0.1).clamp(8, 200), color: Colors.black), // Biểu tượng
              SizedBox(height: 5), // Khoảng cách giữa icon và chữ
              Text(
                label,
                style: TextStyle(fontSize: (width * 0.1).clamp(8, 200)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
