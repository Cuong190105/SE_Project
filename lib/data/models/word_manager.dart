import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eng_dictionary/core/services/api_service.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'word_set.dart';

class WordManager {
  static Future<List<WordSet>> getSets() async {
    try {
      return await DatabaseHelper.instance.getWordSets();
    } catch (e) {
      debugPrint('Lỗi lấy danh sách từ: $e');
      return [];
    }
  }

  static Future<bool> addWordToSet(String wordId) async {
    try {
      final sets = await getSets();
      final set = sets.firstWhere((set) => set.id == wordId);

      final vocab = WordSet(
        id: set.id,
        word: set.word,
        userEmail: set.userEmail,
        meanings: set.meanings,
        synonyms: set.synonyms,
        antonyms: set.antonyms,
        family: set.family,
        phrases: set.phrases,
        deleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
        isSample: set.isSample,
      );
      await DatabaseHelper.instance.insertWordSets(vocab);
      return true;
    } catch (e, stackTrace) {
      debugPrint('Lỗi thêm từ: $e\n$stackTrace');
      return false;
    }
  }

  static Future<bool> updateWord(String wordId) async {
    try {
      final sets = await getSets();
      final set = sets.firstWhere((set) => set.id == wordId);
      final updated = WordSet(
        id: set.id,
        word: set.word,
        userEmail: set.userEmail,
        meanings: set.meanings,
        synonyms: set.synonyms,
        antonyms: set.antonyms,
        family: set.family,
        phrases: set.phrases,
        deleted: false,
        createdAt: set.createdAt,
        updatedAt: DateTime.now(),
        isSynced: false,
        isSample: set.isSample,
      );
      await DatabaseHelper.instance.insertWordSets(updated);
      return true;
    } catch (e, stackTrace) {
      debugPrint('Lỗi cập nhật từ: $e\n$stackTrace');
      return false;
    }
  }

  static Future<bool> deleteWord(String id) async {
    try {
      await DatabaseHelper.instance.deleteWordSets(id);
      return true;
    } catch (e, stackTrace) {
      debugPrint('Lỗi xóa từ: $e\n$stackTrace');
      return false;
    }
  }

  static Future<void> syncOnStartup() async {
    debugPrint('Bắt đầu đồng bộ từ vựng với server...');
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) return;

      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email') ?? 'unknown_user@example.com';
      final lastSync = prefs.getString('vocab_last_sync') ?? '1970-01-01T00:00:00.000Z';

      final response = await ApiService.get('sync/downloadVocabularies?timestamp=$lastSync');
      final vocabList = (response['payload'] as List)
          .map((json) => WordSet.fromJson(json))
          .where((v) => v.userEmail == userEmail)
          .toList();

      for (var vocab in vocabList) {
        await DatabaseHelper.instance.insertWordSets(vocab);
      }

      await prefs.setString('vocab_last_sync', DateTime.now().toIso8601String());
      debugPrint('Đồng bộ từ vựng hoàn tất.');
    } catch (e, stackTrace) {
      debugPrint('Lỗi đồng bộ từ server: $e\n$stackTrace');
    }
  }

  static Future<Map<String, dynamic>> syncToServer() async {
    debugPrint('Bắt đầu đồng bộ từ vựng lên server...');
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        return {'success': false, 'message': 'Không có kết nối mạng'};
      }

      final unsynced = await DatabaseHelper.instance.getUnsyncedWordSets();
      if (unsynced.isEmpty) {
        return {'success': true, 'message': 'Không có từ cần đồng bộ'};
      }

      final response = await ApiService.post('sync/uploadVocabularies', {
        'payload': unsynced.map((v) => v.toJson()).toList(),
      });

      if (response['errors'] != null && response['errors'].isNotEmpty) {
        return {'success': false, 'message': response['errors'].join(', ')};
      }

      for (var vocab in unsynced) {
        await DatabaseHelper.instance.markWordSetAsSynced(vocab.id);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('vocab_last_sync', DateTime.now().toIso8601String());

      return {'success': true, 'message': 'Đồng bộ thành công'};
    } catch (e, stackTrace) {
      debugPrint('Lỗi đồng bộ lên server: $e\n$stackTrace');
      return {'success': false, 'message': e.toString()};
    }
  }
}
