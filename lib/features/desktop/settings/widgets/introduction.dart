import 'package:flutter/material.dart';

class Introduction extends StatelessWidget {
  const Introduction({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Giới thiệu', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text(
            'Đây là ứng dụng giúp bạn học tiếng anh Đây là ứng dụng giúp bạn học tiếng anh' +
                'Đây là ứng dụng giúp bạn học tiếng anh Đây là ứng dụng giúp bạn học tiếng anh'
            ,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Xử lý khi nhấn nút giới thiệu
            },
            child: Text('Tìm hiểu thêm'),
          ),
        ],
      ),
    );
  }
}
