import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

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

class Vocabulary {
  final String word;
  final String definition;

  Vocabulary({required this.word, required this.definition});
}

class QuizManager {
  static List<Vocabulary> _vocabulary = [];

  // Tải từ vựng từ file JSON
  static Future<void> loadVocabulary() async {
    try {
      final jsonString = await rootBundle.loadString('assets/vocabulary.json');
      final List<dynamic> jsonData = jsonDecode(jsonString);
      _vocabulary = jsonData.map((json) => Vocabulary(
        word: json['word'],
        definition: json['definition'],
      )).toList();
    } catch (e) {
      print('Lỗi khi tải từ vựng: $e');
      // Dữ liệu dự phòng
      _vocabulary = [
        Vocabulary(word: 'Happy', definition: 'Vui vẻ'),
        Vocabulary(word: 'Sad', definition: 'Buồn bã'),
        Vocabulary(word: 'Angry', definition: 'Tức giận'),
        Vocabulary(word: 'Tired', definition: 'Mệt mỏi'),
        Vocabulary(word: 'Big', definition: 'Lớn'),
        Vocabulary(word: 'Small', definition: 'Nhỏ'),
        Vocabulary(word: 'Fast', definition: 'Nhanh'),
        Vocabulary(word: 'Slow', definition: 'Chậm'),
        Vocabulary(word: 'Beautiful', definition: 'Xinh đẹp'),
        Vocabulary(word: 'Ugly', definition: 'Xấu xí'),
        Vocabulary(word: 'Strong', definition: 'Mạnh mẽ'),
        Vocabulary(word: 'Weak', definition: 'Yếu đuối'),
      ];
    }
  }

  // Tạo 10 câu hỏi trắc nghiệm ngẫu nhiên
  static List<QuizQuestion> generateQuizQuestions() {
    final random = Random();
    final List<QuizQuestion> questions = [];
    final List<int> selectedIndices = [];

    // Chọn 10 từ ngẫu nhiên
    while (selectedIndices.length < 10 && selectedIndices.length < _vocabulary.length) {
      final index = random.nextInt(_vocabulary.length);
      if (!selectedIndices.contains(index)) {
        selectedIndices.add(index);
      }
    }

    for (int i = 0; i < selectedIndices.length; i++) {
      final vocab = _vocabulary[selectedIndices[i]];
      final correctDefinition = vocab.definition;
      final options = [correctDefinition];

      // Chọn 3 đáp án sai ngẫu nhiên
      while (options.length < 4) {
        final wrongIndex = random.nextInt(_vocabulary.length);
        final wrongDefinition = _vocabulary[wrongIndex].definition;
        if (wrongIndex != selectedIndices[i] && !options.contains(wrongDefinition)) {
          options.add(wrongDefinition);
        }
      }

      // Xáo trộn đáp án
      options.shuffle(random);
      final correctAnswerIndex = options.indexOf(correctDefinition);

      questions.add(
        QuizQuestion(
          question: 'Nghĩa của từ "${vocab.word}" là gì?',
          options: options,
          correctAnswerIndex: correctAnswerIndex,
          explanation: 'Từ "${vocab.word}" có nghĩa là "$correctDefinition" trong tiếng Việt.',
          type: QuestionType.multipleChoice,
        ),
      );
    }

    return questions;
  }
}