import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eng_dictionary/back_end/api_service.dart';
import 'package:eng_dictionary/database_SQLite/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class FlashcardSet {
  String id;
  String name;
  String description;
  List<Flashcard> cards;
  Color color;
  int progress;
  DateTime createdAt;
  DateTime updatedAt;
  bool isSynced;

  FlashcardSet({
    required this.id,
    required this.name,
    this.description = '',
    required this.cards,
    required this.color,
    this.progress = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  int get totalCards => cards.length;

  double get progressPercentage => totalCards > 0 ? progress / totalCards : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'set_id': id,
      'name': name,
      'description': description,
      'cards': cards.map((card) => card.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory FlashcardSet.fromJson(Map<String, dynamic> json) {
    return FlashcardSet(
      id: json['set_id'],
      name: json['name'],
      description: json['description'] ?? '',
      cards: (json['cards'] as List)
          .map((cardJson) => Flashcard.fromJson(cardJson))
          .toList(),
      color: Colors.blue.shade700, // Sẽ được gán sau
      progress: json['cards']?.where((card) => card['isLearned'] ?? false).length ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isSynced: true,
    );
  }
}

class Flashcard {
  String id;
  String frontContent;
  String backContent;
  bool isLearned;

  Flashcard({
    required this.id,
    required this.frontContent,
    required this.backContent,
    this.isLearned = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'front': frontContent,
      'back': backContent,
      'isLearned': isLearned,
    };
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] ?? 'card_${DateTime.now().millisecondsSinceEpoch}',
      frontContent: json['front'],
      backContent: json['back'],
      isLearned: json['isLearned'] ?? false,
    );
  }
}

class FlashcardManager {
  static final List<Color> _defaultColors = [
    Colors.blue.shade700,
    Colors.purple.shade700,
    Colors.teal.shade700,
    Colors.amber.shade700,
    Colors.red.shade700,
    Colors.green.shade700,
    Colors.indigo.shade700,
    Colors.orange.shade700,
  ];

  static Color getColorForIndex(int index) {
    return _defaultColors[index % _defaultColors.length];
  }

  // Tải dữ liệu từ cơ sở dữ liệu cục bộ
  static Future<List<FlashcardSet>> getSets() async {
    debugPrint('Fetching flashcard sets from database...');
    try {
      final sets = await DatabaseHelper.instance.getFlashcardSets();
      debugPrint('Fetched ${sets.length} flashcard sets from database.');
      return sets;
    } catch (e, stackTrace) {
      debugPrint('Error fetching flashcard sets: $e\n$stackTrace');
      rethrow;
    }
  }

  // Tải dữ liệu từ server khi mở ứng dụng
  static Future<void> syncOnStartup() async {
    debugPrint('Starting server sync...');
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getString('last_sync_timestamp') ?? '1970-01-01T00:00:00.000Z';
      final formatter = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
      final formattedLastSync = formatter.format(DateTime.parse(lastSync));

      final response = await ApiService.get('sync/downloadFlashcards?timestamp=$formattedLastSync')
          .timeout(Duration(seconds: 10), onTimeout: () {
        throw Exception('Server sync timed out after 10 seconds');
      });

      final sets = (response['payload'] as List)
          .map((json) => FlashcardSet.fromJson(json))
          .toList();

      for (var set in sets) {
        set.color = getColorForIndex((await getSets()).length);
        await DatabaseHelper.instance.insertFlashcardSet(set);
      }

      await prefs.setString('last_sync_timestamp', DateTime.now().toIso8601String());
      debugPrint('Server sync completed successfully.');
    } catch (e, stackTrace) {
      debugPrint('Error syncing flashcards from server: $e\n$stackTrace');
      // Không ném lỗi để tránh treo ứng dụng
    }
  }

  // Tạo bộ flashcard mới
  static Future<FlashcardSet> createNewSet(String name, String description) async {
    debugPrint('Creating new flashcard set: $name');
    try {
      final newId = 'set_${DateTime.now().millisecondsSinceEpoch}';
      final newSet = FlashcardSet(
        id: newId,
        name: name,
        description: description,
        cards: [],
        color: _defaultColors[(await getSets()).length % _defaultColors.length],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      await DatabaseHelper.instance.insertFlashcardSet(newSet);
      debugPrint('Created new flashcard set: $newId');
      return newSet;
    } catch (e, stackTrace) {
      debugPrint('Error creating new flashcard set: $e\n$stackTrace');
      rethrow;
    }
  }

  // Đổi tên bộ flashcard
  static Future<void> renameSet(String setId, String newName) async {
    debugPrint('Renaming flashcard set: $setId to $newName');
    try {
      final sets = await getSets();
      final setIndex = sets.indexWhere((set) => set.id == setId);
      if (setIndex == -1) {
        throw Exception('Flashcard set not found');
      }

      sets[setIndex].name = newName;
      sets[setIndex].updatedAt = DateTime.now();
      sets[setIndex].isSynced = false;

      await DatabaseHelper.instance.insertFlashcardSet(sets[setIndex]);
      debugPrint('Renamed flashcard set: $setId');
    } catch (e, stackTrace) {
      debugPrint('Error renaming flashcard set: $e\n$stackTrace');
      rethrow;
    }
  }

  // Xóa bộ flashcard
  static Future<void> deleteSet(String setId) async {
    debugPrint('Deleting flashcard set: $setId');
    try {
      await DatabaseHelper.instance.deleteFlashcardSet(setId);
      debugPrint('Deleted flashcard set: $setId');
    } catch (e, stackTrace) {
      debugPrint('Error deleting flashcard set: $e\n$stackTrace');
      rethrow;
    }
  }

  // Thêm thẻ vào bộ flashcard
  static Future<Flashcard> addCardToSet(
      String setId, String frontContent, String backContent) async {
    debugPrint('Adding card to set: $setId');
    try {
      final sets = await getSets();
      final setIndex = sets.indexWhere((set) => set.id == setId);
      if (setIndex == -1) {
        throw Exception('Flashcard set not found');
      }

      final newCard = Flashcard(
        id: 'card_${DateTime.now().millisecondsSinceEpoch}',
        frontContent: frontContent,
        backContent: backContent,
      );

      sets[setIndex].cards.add(newCard);
      sets[setIndex].updatedAt = DateTime.now();
      sets[setIndex].isSynced = false;

      await DatabaseHelper.instance.insertFlashcardSet(sets[setIndex]);
      debugPrint('Added card to set: $setId');
      return newCard;
    } catch (e, stackTrace) {
      debugPrint('Error adding card to set: $e\n$stackTrace');
      rethrow;
    }
  }

  // Cập nhật thẻ
  static Future<void> updateCard(
      String setId, String cardId, String frontContent, String backContent) async {
    debugPrint('Updating card: $cardId in set: $setId');
    try {
      final sets = await getSets();
      final setIndex = sets.indexWhere((set) => set.id == setId);
      if (setIndex == -1) {
        throw Exception('Flashcard set not found');
      }

      final cardIndex = sets[setIndex].cards.indexWhere((card) => card.id == cardId);
      if (cardIndex == -1) {
        throw Exception('Flashcard not found');
      }

      sets[setIndex].cards[cardIndex].frontContent = frontContent;
      sets[setIndex].cards[cardIndex].backContent = backContent;
      sets[setIndex].updatedAt = DateTime.now();
      sets[setIndex].isSynced = false;

      await DatabaseHelper.instance.insertFlashcardSet(sets[setIndex]);
      debugPrint('Updated card: $cardId');
    } catch (e, stackTrace) {
      debugPrint('Error updating card: $e\n$stackTrace');
      rethrow;
    }
  }

  // Xóa thẻ
  static Future<void> deleteCard(String setId, String cardId) async {
    debugPrint('Deleting card: $cardId from set: $setId');
    try {
      final sets = await getSets();
      final setIndex = sets.indexWhere((set) => set.id == setId);
      if (setIndex == -1) {
        throw Exception('Flashcard set not found');
      }

      sets[setIndex].cards.removeWhere((card) => card.id == cardId);
      sets[setIndex].updatedAt = DateTime.now();
      sets[setIndex].isSynced = false;

      await DatabaseHelper.instance.deleteFlashcard(cardId);
      await DatabaseHelper.instance.insertFlashcardSet(sets[setIndex]);
      debugPrint('Deleted card: $cardId');
    } catch (e, stackTrace) {
      debugPrint('Error deleting card: $e\n$stackTrace');
      rethrow;
    }
  }

  // Đánh dấu thẻ đã học
  static Future<void> markCardAsLearned(String setId, String cardId, bool isLearned) async {
    debugPrint('Marking card: $cardId as learned: $isLearned in set: $setId');
    try {
      final sets = await getSets();
      final setIndex = sets.indexWhere((set) => set.id == setId);
      if (setIndex == -1) {
        throw Exception('Flashcard set not found');
      }

      final cardIndex = sets[setIndex].cards.indexWhere((card) => card.id == cardId);
      if (cardIndex == -1) {
        throw Exception('Flashcard not found');
      }

      sets[setIndex].cards[cardIndex].isLearned = isLearned;
      sets[setIndex].progress = sets[setIndex].cards.where((card) => card.isLearned).length;
      sets[setIndex].updatedAt = DateTime.now();
      sets[setIndex].isSynced = false;

      await DatabaseHelper.instance.insertFlashcardSet(sets[setIndex]);
      debugPrint('Marked card: $cardId as learned');
    } catch (e, stackTrace) {
      debugPrint('Error marking card as learned: $e\n$stackTrace');
      rethrow;
    }
  }

  // Đồng bộ dữ liệu lên server
  static Future<Map<String, dynamic>> syncToServer() async {
    debugPrint('Starting sync to server...');
    try {
      final unsyncedSets = await DatabaseHelper.instance.getUnsyncedSets();
      if (unsyncedSets.isEmpty) {
        debugPrint('No data to sync.');
        return {'success': true, 'message': 'Không có dữ liệu cần đồng bộ'};
      }

      final response = await ApiService.post('sync/uploadFlashcards', {
        'payload': unsyncedSets.map((set) => set.toJson()).toList(),
      }).timeout(Duration(seconds: 10), onTimeout: () {
        throw Exception('Server sync timed out after 10 seconds');
      });

      if (response['errors'] != null && (response['errors'] as List).isNotEmpty) {
        debugPrint('Sync failed: ${response['errors'].join(', ')}');
        return {
          'success': false,
          'message': 'Đồng bộ thất bại: ${response['errors'].join(', ')}',
        };
      }

      // Đánh dấu các bộ đã đồng bộ
      for (var set in unsyncedSets) {
        await DatabaseHelper.instance.markSetAsSynced(set.id);
      }

      // Cập nhật thời gian đồng bộ
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_sync_timestamp', DateTime.now().toIso8601String());

      debugPrint('Sync to server completed successfully.');
      return {'success': true, 'message': 'Đồng bộ thành công'};
    } catch (e, stackTrace) {
      debugPrint('Error syncing to server: $e\n$stackTrace');
      return {'success': false, 'message': 'Lỗi đồng bộ: $e'};
    }
  }
}