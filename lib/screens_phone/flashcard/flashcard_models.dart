import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eng_dictionary/back_end/services/auth_service.dart';
import 'package:eng_dictionary/database_SQLite/database_helper.dart';
import '../../back_end/api_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
      'is_learned': isLearned,
    };
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'],
      frontContent: json['front'],
      backContent: json['back'],
      isLearned: json['is_learned'] ?? false,
    );
  }
}

class FlashcardSet {
  String id;
  String userEmail;
  String name;
  String description;
  List<Flashcard> cards;
  Color color;
  int progress;
  DateTime createdAt;
  DateTime updatedAt;
  bool isSynced;
  bool isSample;

  FlashcardSet({
    required this.id,
    required this.userEmail,
    required this.name,
    this.description = '',
    required this.cards,
    required this.color,
    this.progress = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.isSample = false,
  });

  int get totalCards => cards.length;

  double get progressPercentage => totalCards > 0 ? progress / totalCards : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'set_id': id,
      'user_email': userEmail,
      'name': name,
      'description': description,
      'cards': cards.map((card) => card.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_sample': isSample ? 1 : 0,
    };
  }

  factory FlashcardSet.fromJson(Map<String, dynamic> json) {
    final cards = (json['cards'] as List).map((cardJson) => Flashcard.fromJson(cardJson)).toList();
    return FlashcardSet(
      id: json['set_id'],
      userEmail: json['user_email'] ?? 'unknown_user@example.com',
      name: json['name'],
      description: json['description'] ?? '',
      cards: cards,
      color: FlashcardManager.getColorForIndex(cards.length),
      progress: cards.where((card) => card.isLearned).length,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isSynced: true,
      isSample: json['is_sample'] == 1,
    );
  }
}

class FlashcardManager {
  static final List<Color> _defaultColors = [
    Colors.blue.shade700,
    Colors.green.shade700,
    Colors.purple.shade700,
    Colors.orange.shade700,
    Colors.red.shade700,
  ];

  static Future<List<FlashcardSet>> getSets() async {
    try {
      return await DatabaseHelper.instance.getFlashcardSets();
    } catch (e) {
      debugPrint('Lỗi lấy danh sách bộ thẻ: $e');
      return [];
    }
  }

  static Future<FlashcardSet> createNewSet(String name, String description) async {
    debugPrint('Tạo bộ thẻ mới: $name');
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email') ?? 'unknown_user@example.com';
      final newId = 'set_${DateTime.now().millisecondsSinceEpoch}';
      final newSet = FlashcardSet(
        id: newId,
        userEmail: userEmail,
        name: name,
        description: description,
        cards: [],
        color: _defaultColors[(await getSets()).length % _defaultColors.length],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
        isSample: false,
      );

      await DatabaseHelper.instance.insertFlashcardSet(newSet);
      debugPrint('Đã tạo bộ thẻ mới: $newId cho người dùng: $userEmail');
      return newSet;
    } catch (e, stackTrace) {
      debugPrint('Lỗi tạo bộ thẻ mới: $e\n$stackTrace');
      rethrow;
    }
  }

  static Future<bool> renameSet(String setId, String newName) async {
    try {
      final sets = await getSets();
      final set = sets.firstWhere((set) => set.id == setId);
      final updatedSet = FlashcardSet(
        id: set.id,
        userEmail: set.userEmail,
        name: newName,
        description: set.description,
        cards: set.cards,
        color: set.color,
        progress: set.progress,
        createdAt: set.createdAt,
        updatedAt: DateTime.now(),
        isSynced: false,
        isSample: set.isSample,
      );

      await DatabaseHelper.instance.insertFlashcardSet(updatedSet);
      debugPrint('Đã đổi tên bộ thẻ $setId thành $newName');
      return true;
    } catch (e, stackTrace) {
      debugPrint('Lỗi đổi tên bộ thẻ $setId: $e\n$stackTrace');
      return false;
    }
  }

  static Future<bool> deleteSet(String setId) async {
    try {
      await DatabaseHelper.instance.deleteFlashcardSet(setId);
      debugPrint('Đã xóa bộ thẻ: $setId');
      return true;
    } catch (e, stackTrace) {
      debugPrint('Lỗi xóa bộ thẻ $setId: $e\n$stackTrace');
      return false;
    }
  }

  static Future<bool> addCardToSet(String setId, String front, String back) async {
    try {
      final sets = await getSets();
      final set = sets.firstWhere((set) => set.id == setId);
      final newCard = Flashcard(
        id: 'card_${DateTime.now().millisecondsSinceEpoch}',
        frontContent: front,
        backContent: back,
      );

      set.cards.add(newCard);
      final updatedSet = FlashcardSet(
        id: set.id,
        userEmail: set.userEmail,
        name: set.name,
        description: set.description,
        cards: set.cards,
        color: set.color,
        progress: set.progress,
        createdAt: set.createdAt,
        updatedAt: DateTime.now(),
        isSynced: false,
        isSample: set.isSample,
      );

      await DatabaseHelper.instance.insertFlashcardSet(updatedSet);
      debugPrint('Đã thêm thẻ vào bộ thẻ $setId');
      return true;
    } catch (e, stackTrace) {
      debugPrint('Lỗi thêm thẻ vào bộ thẻ $setId: $e\n$stackTrace');
      return false;
    }
  }

  static Future<bool> updateCard(String setId, String cardId, String front, String back) async {
    try {
      final sets = await getSets();
      final set = sets.firstWhere((set) => set.id == setId);
      final card = set.cards.firstWhere((card) => card.id == cardId);
      card.frontContent = front;
      card.backContent = back;

      final updatedSet = FlashcardSet(
        id: set.id,
        userEmail: set.userEmail,
        name: set.name,
        description: set.description,
        cards: set.cards,
        color: set.color,
        progress: set.progress,
        createdAt: set.createdAt,
        updatedAt: DateTime.now(),
        isSynced: false,
        isSample: set.isSample,
      );

      await DatabaseHelper.instance.insertFlashcardSet(updatedSet);
      debugPrint('Đã cập nhật thẻ $cardId trong bộ $setId');
      return true;
    } catch (e, stackTrace) {
      debugPrint('Lỗi cập nhật thẻ $cardId trong bộ $setId: $e\n$stackTrace');
      return false;
    }
  }

  static Future<bool> deleteCard(String setId, String cardId) async {
    try {
      final sets = await getSets();
      final set = sets.firstWhere((set) => set.id == setId);
      set.cards.removeWhere((card) => card.id == cardId);

      final updatedSet = FlashcardSet(
        id: set.id,
        userEmail: set.userEmail,
        name: set.name,
        description: set.description,
        cards: set.cards,
        color: set.color,
        progress: set.cards.where((card) => card.isLearned).length,
        createdAt: set.createdAt,
        updatedAt: DateTime.now(),
        isSynced: false,
        isSample: set.isSample,
      );

      await DatabaseHelper.instance.insertFlashcardSet(updatedSet);
      debugPrint('Đã xóa thẻ $cardId khỏi bộ $setId');
      return true;
    } catch (e, stackTrace) {
      debugPrint('Lỗi xóa thẻ $cardId khỏi bộ $setId: $e\n$stackTrace');
      return false;
    }
  }

  static Future<bool> markCardAsLearned(String setId, String cardId, bool isLearned) async {
    try {
      final sets = await getSets();
      final set = sets.firstWhere((set) => set.id == setId);
      final card = set.cards.firstWhere((card) => card.id == cardId);
      card.isLearned = isLearned;

      final updatedSet = FlashcardSet(
        id: set.id,
        userEmail: set.userEmail,
        name: set.name,
        description: set.description,
        cards: set.cards,
        color: set.color,
        progress: set.cards.where((card) => card.isLearned).length,
        createdAt: set.createdAt,
        updatedAt: DateTime.now(),
        isSynced: false,
        isSample: set.isSample,
      );

      await DatabaseHelper.instance.insertFlashcardSet(updatedSet);
      debugPrint('Đã đánh dấu thẻ $cardId trong bộ $setId là ${isLearned ? 'đã học' : 'chưa học'}');
      return true;
    } catch (e, stackTrace) {
      debugPrint('Lỗi đánh dấu thẻ $cardId trong bộ $setId: $e\n$stackTrace');
      return false;
    }
  }

  static Color getColorForIndex(int index) {
    return _defaultColors[index % _defaultColors.length];
  }

  static Future<void> syncOnStartup() async {
    debugPrint('Bắt đầu đồng bộ với server...');
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        debugPrint('Không có kết nối mạng');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email') ?? 'unknown_user@example.com';
      final lastSync = prefs.getString('last_sync_timestamp') ?? '1970-01-01T00:00:00.000Z';
      final formatter = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
      final formattedLastSync = formatter.format(DateTime.parse(lastSync));

      final response = await ApiService.get('sync/downloadFlashcards?timestamp=$formattedLastSync')
          .timeout(Duration(seconds: 10), onTimeout: () {
        throw Exception('Đồng bộ server hết thời gian sau 10 giây');
      });

      final sets = (response['payload'] as List)
          .map((json) => FlashcardSet.fromJson(json))
          .where((set) => set.userEmail == userEmail && !set.isSample)
          .toList();

      for (var set in sets) {
        set.color = getColorForIndex((await getSets()).length);
        await DatabaseHelper.instance.insertFlashcardSet(set);
      }

      await prefs.setString('last_sync_timestamp', DateTime.now().toIso8601String());
      debugPrint('Hoàn tất đồng bộ server cho người dùng: $userEmail.');
    } catch (e, stackTrace) {
      debugPrint('Lỗi đồng bộ thẻ từ server: $e\n$stackTrace');
    }
  }

  static Future<Map<String, dynamic>> syncToServer() async {
    debugPrint('Bắt đầu đồng bộ lên server...');
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return {'success': false, 'message': 'Không có kết nối mạng'};
      }

      final unsyncedSets = await DatabaseHelper.instance.getUnsyncedSets();
      if (unsyncedSets.isEmpty) {
        debugPrint('Không có dữ liệu cần đồng bộ.');
        return {'success': true, 'message': 'Không có dữ liệu cần đồng bộ'};
      }

      final response = await ApiService.post('sync/uploadFlashcards', {
        'payload': unsyncedSets.map((set) => set.toJson()).toList(),
      }).timeout(Duration(seconds: 10), onTimeout: () {
        throw Exception('Đồng bộ server hết thời gian sau 10 giây');
      });

      if (response['errors'] != null && (response['errors'] as List).isNotEmpty) {
        debugPrint('Đồng bộ thất bại: ${response['errors'].join(', ')}');
        return {
          'success': false,
          'message': 'Đồng bộ thất bại: ${response['errors'].join(', ')}',
        };
      }

      for (var set in unsyncedSets) {
        await DatabaseHelper.instance.markSetAsSynced(set.id);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_sync_timestamp', DateTime.now().toIso8601String());

      debugPrint('Hoàn tất đồng bộ lên server.');
      return {'success': true, 'message': 'Đồng bộ thành công'};
    } catch (e, stackTrace) {
      debugPrint('Lỗi đồng bộ lên server: $e\n$stackTrace');
      return {'success': false, 'message': 'Lỗi đồng bộ: $e'};
    }
  }
}