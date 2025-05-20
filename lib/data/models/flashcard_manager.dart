import 'package:flutter/material.dart';
import 'flashcard_set.dart';
import 'flashcard.dart';
import 'database_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eng_dictionary/core/services/auth_service.dart';
import 'database_helper.dart';
import 'package:eng_dictionary/core/services/api_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Flashcard {
  String id;
  String frontContent;
  String backContent;
  bool isLearned;
  bool isDeleted;

  Flashcard({
    required this.id,
    required this.frontContent,
    required this.backContent,
    this.isLearned = false,
    this.isDeleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'front': frontContent,
      'back': backContent,
      'is_learned': isLearned,
      'is_deleted': isDeleted,
    };
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing Flashcard JSON: $json');
    return Flashcard(
      id: json['id']?.toString() ?? 'card_${DateTime.now().millisecondsSinceEpoch}',
      frontContent: json['front']?.toString() ?? '',
      backContent: json['back']?.toString() ?? '',
      isLearned: json['is_learned'] is bool
          ? json['is_learned']
          : (json['is_learned'] is int
          ? json['is_learned'] == 1
          : (json['is_learned'] is String
          ? json['is_learned'].toLowerCase() == 'true' || json['is_learned'] == '1'
          : false)),
      isDeleted: json['is_deleted'] is bool
          ? json['is_deleted']
          : (json['is_deleted'] is int
          ? json['is_deleted'] == 1
          : (json['is_deleted'] is String
          ? json['is_deleted'].toLowerCase() == 'true' || json['is_deleted'] == '1'
          : false)),
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
  bool isDeleted;

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
    this.isDeleted = false,
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
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  static Future<FlashcardSet> fromJson(Map<String, dynamic> json) async {
    debugPrint('Parsing FlashcardSet JSON: $json');
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('user_email') ?? 'unknown_user@example.com';
    final cards = (json['cards'] as List<dynamic>?)?.map((cardJson) {
      if (cardJson is Map<String, dynamic>) {
        return Flashcard.fromJson(cardJson);
      } else {
        debugPrint('Invalid card JSON: $cardJson');
        throw Exception('Định dạng thẻ không hợp lệ trong JSON');
      }
    }).toList() ?? [];

    bool isSample;
    if (json['is_sample'] is int) {
      isSample = json['is_sample'] == 1;
    } else if (json['is_sample'] is String) {
      isSample = json['is_sample'] == '1' || json['is_sample'].toLowerCase() == 'true';
    } else if (json['is_sample'] is bool) {
      isSample = json['is_sample'] as bool;
    } else {
      isSample = false;
    }

    return FlashcardSet(
      id: json['set_id']?.toString() ?? 'set_${DateTime.now().millisecondsSinceEpoch}',
      userEmail: userEmail,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      cards: cards,
      color: FlashcardManager.getColorForIndex(cards.length),
      progress: cards.where((card) => card.isLearned).length,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
      isSynced: true,
      isSample: isSample,
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
        isDeleted: false,
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
      final card = set.cards.firstWhere((card) => card.id == cardId);
      card.isDeleted = true;

      final updatedSet = FlashcardSet(
        id: set.id,
        userEmail: set.userEmail,
        name: set.name,
        description: set.description,
        cards: set.cards,
        color: set.color,
        progress: set.cards.where((card) => card.isLearned && !card.isDeleted).length,
        createdAt: set.createdAt,
        updatedAt: DateTime.now(),
        isSynced: false,
        isSample: set.isSample,
      );

      await DatabaseHelper.instance.insertFlashcardSet(updatedSet);
      debugPrint('Đã đánh dấu xóa thẻ $cardId khỏi bộ $setId');
      return true;
    } catch (e, stackTrace) {
      debugPrint('Lỗi đánh dấu xóa thẻ $cardId khỏi bộ $setId: $e\n$stackTrace');
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
        progress: set.cards.where((card) => card.isLearned && !card.isDeleted).length,
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

      final response = await ApiService.get('sync/downloadWords?timestamp=$formattedLastSync')
          .timeout(Duration(seconds: 10), onTimeout: () {
        throw Exception('Đồng bộ server hết thời gian sau 10 giây');
      });

      debugPrint('Phản hồi từ server: $response');

      // Xử lý response là List hoặc Map
      List<dynamic> payload;
      if (response is List<dynamic>) {
        payload = response;
      } else if (response is Map<String, dynamic> && response.containsKey('payload')) {
        if (response['payload'] is List<dynamic>) {
          payload = response['payload'] as List<dynamic>;
        } else {
          debugPrint('Lỗi: payload không phải List: ${response['payload']}');
          throw Exception('payload phải là một danh sách');
        }
      } else {
        debugPrint('Lỗi: Phản hồi không đúng định dạng: $response');
        throw Exception('Phản hồi từ server không đúng định dạng');
      }

      final sets = <FlashcardSet>[];
      for (var json in payload) {
        if (json is Map<String, dynamic>) {
          final set = await FlashcardSet.fromJson(json);
          if (set.userEmail == userEmail && !set.isSample) {
            sets.add(set);
          }
        } else {
          debugPrint('Invalid set JSON: $json');
          throw Exception('Định dạng bộ thẻ không hợp lệ trong JSON');
        }
      }

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
      debugPrint('Số bộ thẻ chưa đồng bộ: ${unsyncedSets.length}');

      if (unsyncedSets.isEmpty) {
        debugPrint('Tất cả thẻ đã được đồng bộ.');
        return {'success': true, 'message': 'Tất cả thẻ đã được đồng bộ'};
      }

      final response = await ApiService.post('sync/uploadWords', {
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
