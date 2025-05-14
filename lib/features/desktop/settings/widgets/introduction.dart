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
            'Ứng dụng học tiếng Anh của chúng tôi là công cụ hỗ trợ người học mọi trình độ'
                ' nâng cao kỹ năng ngôn ngữ một cách hiệu quả và linh hoạt.'
                ' Với các tính năng như tra từ điển, dịch văn bản, học từ vựng bằng flashcard,'
                ' luyện nghe – nói – đọc – viết, và các trò chơi tương tác, '
                'người dùng có thể học tiếng Anh mọi lúc, mọi nơi.'
                ' Dữ liệu được đồng bộ hóa trên đám mây,'
                ' hỗ trợ lưu trữ từ vựng cá nhân,'
                ' lộ trình học tùy chỉnh và thống kê tiến độ học tập.'
                ' Giao diện thân thiện, dễ sử dụng cùng với nội dung học tập được cập nhật liên tục'
                ' giúp người dùng duy trì động lực và tiến bộ từng ngày.'

            ,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          /*ElevatedButton(
            onPressed: () {
              // Xử lý khi nhấn nút giới thiệu
            },
            child: Text('Tìm hiểu thêm'),
          ),*/
        ],
      ),
    );
  }
}
