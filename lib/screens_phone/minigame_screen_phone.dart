import 'package:flutter/material.dart';
import 'dart:math';

class MinigameScreen extends StatelessWidget {
  const MinigameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trắc nghiệm', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
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

            Container(
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
                    '1. Mỗi câu hỏi có 4 lựa chọn, chỉ có 1 đáp án đúng.\n\n'
                    '2. Chọn đáp án bạn cho là đúng bằng cách nhấn vào nó.\n\n'
                    '3. Nếu chọn đúng, đáp án sẽ hiển thị màu xanh lá cây.\n\n'
                    '4. Nếu chọn sai, đáp án sẽ hiển thị màu đỏ và đáp án đúng sẽ hiển thị màu xanh lá cây.\n\n'
                    '5. Nhấn "Tiếp theo" để chuyển sang câu hỏi tiếp theo.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Start button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuizGameScreen(),
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
    );
  }
}

class QuizGameScreen extends StatefulWidget {
  const QuizGameScreen({super.key});

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> {
  late QuizQuestion currentQuestion;
  int? selectedAnswerIndex;
  bool isAnswerChecked = false;
  int correctAnswers = 0;
  int totalAnswered = 0;

  @override
  void initState() {
    super.initState();
    // Get a random question to start
    currentQuestion = QuizManager.getRandomQuestions(1).first;
  }

  void checkAnswer(int index) {
    if (isAnswerChecked) return;

    setState(() {
      selectedAnswerIndex = index;
      isAnswerChecked = true;
      totalAnswered++;

      if (index == currentQuestion.correctAnswerIndex) {
        correctAnswers++;
      }
    });
  }

  void nextQuestion() {
    setState(() {
      // random câu hỏi
      currentQuestion = QuizManager.getRandomQuestions(1).first;
      selectedAnswerIndex = null;
      isAnswerChecked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trắc nghiệm', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),

            // Question
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    currentQuestion.type == QuestionType.multipleChoice
                        ? 'Chọn đáp án đúng'
                        : 'Điền từ thích hợp',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentQuestion.question,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Options
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion.options.length,
                itemBuilder: (context, index) {
                  final isCorrect = index == currentQuestion.correctAnswerIndex;
                  final isSelected = index == selectedAnswerIndex;

                  // Determine the button color based on selection and correctness
                  Color? buttonColor;
                  Color? textColor;
                  IconData? trailingIcon;

                  if (isAnswerChecked) {
                    if (isCorrect) {
                      buttonColor = Colors.green.shade100;
                      textColor = Colors.green.shade800;
                      trailingIcon = Icons.check_circle;
                    } else if (isSelected) {
                      buttonColor = Colors.red.shade100;
                      textColor = Colors.red.shade800;
                      trailingIcon = Icons.cancel;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ElevatedButton(
                      onPressed:
                          isAnswerChecked ? null : () => checkAnswer(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor ?? Colors.white,
                        foregroundColor: textColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isAnswerChecked && (isCorrect || isSelected)
                                ? (isCorrect ? Colors.green : Colors.red)
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        elevation: isAnswerChecked && (isCorrect || isSelected)
                            ? 4
                            : 1,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${String.fromCharCode(65 + index)}.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: textColor ?? Colors.black,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              currentQuestion.options[index],
                              style: TextStyle(
                                fontSize: 16,
                                color: textColor ?? Colors.black,
                              ),
                            ),
                          ),
                          if (trailingIcon != null)
                            Icon(
                              trailingIcon,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Explanation when answer is checked
            if (isAnswerChecked && currentQuestion.explanation.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giải thích:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentQuestion.explanation,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

            // Next button
            if (isAnswerChecked)
              ElevatedButton(
                onPressed: nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Tiếp theo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final QuestionType type;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation = '',
    this.type = QuestionType.multipleChoice,
  });
}

enum QuestionType {
  multipleChoice,
  fillInTheBlank,
}

class QuizManager {
  static final List<QuizQuestion> _questions = [
    QuizQuestion(
      question: 'What is the meaning of "Gay"?',
      options: ['Đẹp trai', 'Vai gãy', 'con chó', 'con gà'],
      correctAnswerIndex: 1,
      explanation: '"Gay" means "Vai gãy" in Vietnamese.',
    ),
    QuizQuestion(
      question: 'Ai đẹp trai nhất nhóm".',
      options: ['Tuấn', 'Giống câu A', 'Giống câu B', 'Cả 3 đáp án trên'],
      correctAnswerIndex: 3,
      explanation: '"No need explanation',
    ),
    QuizQuestion(
      question: 'What does "supercalifragilisticexpialidocious" mean?',
      options: ['Tuyệt vời', 'ko biết', 'buồn', 'vui'],
      correctAnswerIndex: 0,
      explanation: '"supercalifragilisticexpialidocious" means "tuyệt vời" in Vietnamese.',
    ),
    QuizQuestion(
      question: '1 + 1 = ?".',
      options: ['2', '3', '4', '5'],
      correctAnswerIndex: 0,
      explanation: '"2',
    ),
    QuizQuestion(
      question: 'Bạn có gay ko?',
      options: ['có', 'có', 'có', 'có'],
      correctAnswerIndex: 0,
      explanation: '"ok',
    ),
  ];

  static List<QuizQuestion> getRandomQuestions(int count) {
    if (count >= _questions.length) {
      return List.from(_questions);
    }

    final random = Random();
    final List<QuizQuestion> selectedQuestions = [];
    final List<int> indices =
        List.generate(_questions.length, (index) => index);

    // Shuffle the indices
    indices.shuffle(random);

    // Take the first 'count' indices
    for (int i = 0; i < count; i++) {
      selectedQuestions.add(_questions[indices[i]]);
    }

    return selectedQuestions;
  }
}

