import 'package:flutter/material.dart';
import 'package:eng_dictionary/features/desktop/minigame/quiz_question.dart';
import 'dart:async';

class QuizGameScreenPhone extends StatefulWidget {
  const QuizGameScreenPhone({super.key});

  @override
  State<QuizGameScreenPhone> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreenPhone> {
  late List<QuizQuestion> questions;
  int currentQuestionIndex = 0;
  int? selectedAnswerIndex;
  bool isAnswerChecked = false;
  int correctAnswers = 0;
  int totalAnswered = 0;
  int timeLeft = 30;
  Timer? timer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    await QuizManager.loadVocabulary();
    setState(() {
      questions = QuizManager.generateQuizQuestions();
      isLoading = false;
      startTimer();
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          timer.cancel();
          checkAnswer(-1); // Hết giờ, coi như trả lời sai
        }
      });
    });
  }

  void checkAnswer(int index) {
    if (isAnswerChecked) return;

    timer?.cancel();
    setState(() {
      selectedAnswerIndex = index;
      isAnswerChecked = true;
      totalAnswered++;

      if (index == questions[currentQuestionIndex].correctAnswerIndex) {
        correctAnswers++;
      }
    });
  }

  void nextQuestion() {
    timer?.cancel();
    if (currentQuestionIndex + 1 >= questions.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(
            correctAnswers: correctAnswers,
            totalQuestions: totalAnswered,
          ),
        ),
      );
    } else {
      setState(() {
        currentQuestionIndex++;
        selectedAnswerIndex = null;
        isAnswerChecked = false;
        timeLeft = 30;
        startTimer();
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text('Trắc nghiệm', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),

            // Timer
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Thời gian: $timeLeft giây',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

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
                    'Câu ${currentQuestionIndex + 1}/10',
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
                      onPressed: isAnswerChecked ? null : () => checkAnswer(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor ?? Colors.white,
                        foregroundColor: textColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isAnswerChecked && (isCorrect || isSelected)
                                ? (isCorrect ? Colors.green : Colors.red)
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        elevation: isAnswerChecked && (isCorrect || isSelected) ? 4 : 1,
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

            // Explanation
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
                child: Text(
                  currentQuestionIndex + 1 == questions.length ? 'Kết thúc' : 'Tiếp theo',
                  style: const TextStyle(
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

class QuizResultScreen extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;

  const QuizResultScreen({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bạn trả lời đúng $correctAnswers/$totalQuestions câu!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuizGameScreenPhone(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Chơi lại',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Quay lại',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}