import 'package:flutter/material.dart';
import 'dart:math';

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
      explanation:
          '"supercalifragilisticexpialidocious" means "tuyệt vời" in Vietnamese.',
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
