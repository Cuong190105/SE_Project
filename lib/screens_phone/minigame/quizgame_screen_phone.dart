import 'package:flutter/material.dart';
import 'quiz_question.dart';

class QuizGameScreenPhone extends StatefulWidget {
  const QuizGameScreenPhone({super.key});

  @override
  State<QuizGameScreenPhone> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreenPhone> {
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
        backgroundColor: Colors.blue.shade700,
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
