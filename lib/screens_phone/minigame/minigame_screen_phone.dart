import 'package:flutter/material.dart';
import 'quizgame_screen_phone.dart';

class MinigameScreen extends StatelessWidget {
  const MinigameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minigame', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),

              // Game title
              Text(
                'Trò chơi trắc nghiệm',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 20),

              // Hướng dẫn
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.55, // Giới hạn chiều cao
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      'Hướng dẫn',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '1. Trò chơi gồm 10 câu hỏi, mỗi câu có 4 lựa chọn, chỉ có 1 đáp án đúng.\n\n'
                          '2. Bạn có 30 giây để trả lời mỗi câu hỏi.\n\n'
                          '3. Chọn đáp án bạn cho là đúng bằng cách nhấn vào nó.\n\n'
                          '4. Nếu chọn đúng, đáp án sẽ hiển thị màu xanh lá cây.\n\n'
                          '5. Nếu chọn sai hoặc hết giờ, đáp án sẽ hiển thị màu đỏ và đáp án đúng sẽ hiển thị màu xanh lá cây.\n\n'
                          '6. Nhấn "Tiếp theo" để chuyển sang câu hỏi tiếp theo.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Start button
              ElevatedButton(
                onPressed: () {
                  print('Nhấn nút Bắt đầu, chuyển đến QuizGameScreenPhone');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QuizGameScreenPhone(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Bắt đầu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}