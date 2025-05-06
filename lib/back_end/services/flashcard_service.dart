// lib/services/flashcard_service.dart
import 'package:eng_dictionary/back_end/api_service.dart';

class FlashcardService {
  // Tải lên Flashcard
  static Future<Map<String, dynamic>> uploadFlashcards(List<Map<String, dynamic>> flashcards) async {
    try {
      final response = await ApiService.post('sync/uploadFlashcards', {
        'payload': flashcards
      });

      return response;
    } catch (e) {
      print('Lỗi tải lên flashcard: $e');
      return {'errors': []};
    }
  }

  // Tải xuống Flashcard mới
  static Future<List<Map<String, dynamic>>> downloadFlashcards(String timestamp) async {
    try {
      final response = await ApiService.get('sync/downloadFlashcards?timestamp=$timestamp');
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      print('Lỗi tải xuống flashcard: $e');
      return [];
    }
  }
}