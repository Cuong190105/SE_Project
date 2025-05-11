import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;
import 'package:eng_dictionary/data/models/flashcard.dart';
import 'package:eng_dictionary/data/models/flashcard_set.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  sqlite3.Database? _db;
  bool _isInitializing = false;

  DatabaseHelper._instance();

  Future<sqlite3.Database> get database async {
    if (_db != null) return _db!;
    if (_isInitializing) {
      debugPrint('Đang khởi tạo cơ sở dữ liệu, chờ...');
      while (_isInitializing) {
        await Future.delayed(Duration(milliseconds: 10));
      }
      return _db!;
    }
    _isInitializing = true;
    try {
      _db = await _initDB('flashcards.db');
      return _db!;
    } finally {
      _isInitializing = false;
    }
  }

  Future<sqlite3.Database> _initDB(String fileName) async {
    debugPrint('Khởi tạo cơ sở dữ liệu: $fileName');
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, fileName);
      final db = sqlite3.sqlite3.open(path);

      debugPrint('Tạo bảng...');
      db.execute('''
        CREATE TABLE IF NOT EXISTS flashcard_sets (
          set_id TEXT PRIMARY KEY,
          user_email TEXT NOT NULL,
          name TEXT NOT NULL,
          description TEXT,
          color INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          is_synced INTEGER NOT NULL DEFAULT 0,
          is_sample INTEGER NOT NULL DEFAULT 0
        )
      ''');

      db.execute('''
        CREATE TABLE IF NOT EXISTS flashcards (
          id TEXT PRIMARY KEY,
          set_id TEXT NOT NULL,
          front TEXT NOT NULL,
          back TEXT NOT NULL,
          is_learned INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (set_id) REFERENCES flashcard_sets (set_id)
        )
      ''');

      db.execute('CREATE INDEX IF NOT EXISTS idx_flashcard_sets_user_email ON flashcard_sets(user_email)');
      db.execute('CREATE INDEX IF NOT EXISTS idx_flashcards_set_id ON flashcards(set_id)');

      debugPrint('Hoàn tất khởi tạo cơ sở dữ liệu.');
      return db;
    } catch (e, stackTrace) {
      debugPrint('Lỗi khởi tạo cơ sở dữ liệu: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> _insertSampleFlashcardSets(sqlite3.Database db) async {
    try {
      db.execute('BEGIN TRANSACTION');
      final now = DateTime.now().toIso8601String();

      final existingSets = db.select('SELECT set_id FROM flashcard_sets WHERE set_id IN (?, ?)', ['animals_001', 'music_001']);
      final existingSetIds = existingSets.map((row) => row['set_id'] as String).toSet();

      if (!existingSetIds.contains('animals_001')) {
        debugPrint('Chèn bộ Động vật...');
        db.execute('''
          INSERT INTO flashcard_sets (set_id, user_email, name, description, color, created_at, updated_at, is_synced, is_sample)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
          'animals_001',
          'sample@example.com',
          'Động vật',
          'Từ vựng về các loài động vật',
          Colors.blue.shade700.value,
          now,
          now,
          1,
          1
        ]);

        final animalCards = [
          {'id': 'animal_001', 'front': 'Cat', 'back': 'Mèo'},
          {'id': 'animal_002', 'front': 'Dog', 'back': 'Chó'},
          {'id': 'animal_003', 'front': 'Elephant', 'back': 'Voi'},
          {'id': 'animal_004', 'front': 'Tiger', 'back': 'Hổ'},
          {'id': 'animal_005', 'front': 'Lion', 'back': 'Sư tử'},
          {'id': 'animal_006', 'front': 'Bear', 'back': 'Gấu'},
          {'id': 'animal_007', 'front': 'Fox', 'back': 'Cáo'},
          {'id': 'animal_008', 'front': 'Wolf', 'back': 'Sói'},
          {'id': 'animal_009', 'front': 'Deer', 'back': 'Hươu'},
          {'id': 'animal_010', 'front': 'Horse', 'back': 'Ngựa'},
        ];

        for (var card in animalCards) {
          db.execute('''
            INSERT INTO flashcards (id, set_id, front, back, is_learned)
            VALUES (?, ?, ?, ?, ?)
          ''', [
            card['id'],
            'animals_001',
            card['front'],
            card['back'],
            0
          ]);
        }
      }

      if (!existingSetIds.contains('music_001')) {
        debugPrint('Chèn bộ Âm nhạc...');
        db.execute('''
          INSERT INTO flashcard_sets (set_id, user_email, name, description, color, created_at, updated_at, is_synced, is_sample)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
          'music_001',
          'sample@example.com',
          'Âm nhạc',
          'Thuật ngữ âm nhạc cơ bản',
          Colors.purple.shade700.value,
          now,
          now,
          1,
          1
        ]);

        final musicCards = [
          {'id': 'music_001', 'front': 'Note', 'back': 'Nốt nhạc'},
          {'id': 'music_002', 'front': 'Rhythm', 'back': 'Nhịp điệu'},
          {'id': 'music_003', 'front': 'Melody', 'back': 'Giai điệu'},
          {'id': 'music_004', 'front': 'Harmony', 'back': 'Hòa âm'},
          {'id': 'music_005', 'front': 'Chord', 'back': 'Hợp âm'},
          {'id': 'music_006', 'front': 'Scale', 'back': 'Gam'},
          {'id': 'music_007', 'front': 'Tempo', 'back': 'Nhịp độ'},
          {'id': 'music_008', 'front': 'Pitch', 'back': 'Độ cao'},
          {'id': 'music_009', 'front': 'Timbre', 'back': 'Âm sắc'},
          {'id': 'music_010', 'front': 'Dynamics', 'back': 'Cường độ'},
        ];

        for (var card in musicCards) {
          db.execute('''
            INSERT INTO flashcards (id, set_id, front, back, is_learned)
            VALUES (?, ?, ?, ?, ?)
          ''', [
            card['id'],
            'music_001',
            card['front'],
            card['back'],
            0
          ]);
        }
      }

      db.execute('COMMIT');
      debugPrint('Chèn dữ liệu mẫu thành công.');
    } catch (e, stackTrace) {
      db.execute('ROLLBACK');
      debugPrint('Lỗi chèn dữ liệu mẫu: $e\n$stackTrace');
      throw Exception('Không thể chèn dữ liệu mẫu. Vui lòng thử lại.');
    }
  }

  Future<void> ensureSampleFlashcards() async {
    final db = await database;
    try {
      final sampleCount = db.select('SELECT COUNT(*) as count FROM flashcard_sets WHERE is_sample = 1');
      if (sampleCount.first['count'] == 0) {
        debugPrint('Chèn dữ liệu mẫu vì không tìm thấy...');
        await _insertSampleFlashcardSets(db);
      } else {
        debugPrint('Dữ liệu mẫu đã tồn tại.');
      }
    } catch (e, stackTrace) {
      debugPrint('Lỗi kiểm tra dữ liệu mẫu: $e\n$stackTrace');
      throw Exception('Không thể kiểm tra dữ liệu mẫu.');
    }
  }

  Future<void> insertFlashcardSet(FlashcardSet set) async {
    final db = await database;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email') ?? set.userEmail;

      db.execute('''
        INSERT OR REPLACE INTO flashcard_sets (set_id, user_email, name, description, color, created_at, updated_at, is_synced, is_sample)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        set.id,
        userEmail,
        set.name,
        set.description,
        set.color.value,
        set.createdAt.toIso8601String(),
        set.updatedAt.toIso8601String(),
        set.isSynced ? 1 : 0,
        set.isSample ? 1 : 0,
      ]);

      db.execute('DELETE FROM flashcards WHERE set_id = ?', [set.id]);

      for (var card in set.cards) {
        db.execute('''
          INSERT INTO flashcards (id, set_id, front, back, is_learned)
          VALUES (?, ?, ?, ?, ?)
        ''', [
          card.id,
          set.id,
          card.frontContent,
          card.backContent,
          card.isLearned ? 1 : 0,
        ]);
      }
      debugPrint('Bộ thẻ ${set.id} đã được lưu thành công.');
    } catch (e, stackTrace) {
      debugPrint('Lỗi lưu bộ thẻ ${set.id}: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<List<FlashcardSet>> getFlashcardSets() async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('user_email') ?? 'unknown_user@example.com';
    debugPrint('Lấy danh sách bộ thẻ cho người dùng: $userEmail và bộ mẫu...');

    try {
      final setRows = db.select(
        'SELECT * FROM flashcard_sets WHERE user_email = ? OR is_sample = 1',
        [userEmail],
      );
      List<FlashcardSet> sets = [];

      for (var setRow in setRows) {
        final cardRows = db.select(
          'SELECT * FROM flashcards WHERE set_id = ?',
          [setRow['set_id']],
        );

        sets.add(FlashcardSet(
          id: setRow['set_id'] as String,
          userEmail: setRow['user_email'] as String,
          name: setRow['name'] as String,
          description: setRow['description'] as String? ?? '',
          cards: cardRows
              .map((cardRow) => Flashcard(
            id: cardRow['id'] as String,
            frontContent: cardRow['front'] as String,
            backContent: cardRow['back'] as String,
            isLearned: (cardRow['is_learned'] as int) == 1,
          ))
              .toList(),
          color: Color(setRow['color'] as int),
          progress: cardRows.where((card) => card['is_learned'] == 1).length,
          createdAt: DateTime.parse(setRow['created_at'] as String),
          updatedAt: DateTime.parse(setRow['updated_at'] as String),
          isSynced: (setRow['is_synced'] as int) == 1,
          isSample: (setRow['is_sample'] as int) == 1,
        ));
      }

      debugPrint('Đã lấy ${sets.length} bộ thẻ cho người dùng: $userEmail.');
      return sets;
    } catch (e, stackTrace) {
      debugPrint('Lỗi lấy danh sách bộ thẻ: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<List<FlashcardSet>> getUnsyncedSets() async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('user_email');
    if (userEmail == null) {
      debugPrint('Không tìm thấy email người dùng.');
      return [];
    }
    debugPrint('Lấy danh sách bộ thẻ chưa đồng bộ cho người dùng: $userEmail...');

    try {
      final setRows = db.select(
          'SELECT * FROM flashcard_sets WHERE is_synced = 0 AND user_email = ? AND is_sample = 0', [userEmail]);
      List<FlashcardSet> sets = [];

      for (var setRow in setRows) {
        final cardRows = db.select(
          'SELECT * FROM flashcards WHERE set_id = ?',
          [setRow['set_id']],
        );

        sets.add(FlashcardSet(
          id: setRow['set_id'] as String,
          userEmail: setRow['user_email'] as String,
          name: setRow['name'] as String,
          description: setRow['description'] as String? ?? '',
          cards: cardRows
              .map((cardRow) => Flashcard(
            id: cardRow['id'] as String,
            frontContent: cardRow['front'] as String,
            backContent: cardRow['back'] as String,
            isLearned: (cardRow['is_learned'] as int) == 1,
          ))
              .toList(),
          color: Color(setRow['color'] as int),
          progress: cardRows.where((card) => card['is_learned'] == 1).length,
          createdAt: DateTime.parse(setRow['created_at'] as String),
          updatedAt: DateTime.parse(setRow['updated_at'] as String),
          isSynced: false,
          isSample: (setRow['is_sample'] as int) == 1,
        ));
      }

      debugPrint('Đã lấy ${sets.length} bộ thẻ chưa đồng bộ cho người dùng: $userEmail.');
      return sets;
    } catch (e, stackTrace) {
      debugPrint('Lỗi lấy danh sách bộ thẻ chưa đồng bộ: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> markSetAsSynced(String setId) async {
    final db = await database;
    try {
      db.execute(
        'UPDATE flashcard_sets SET is_synced = 1 WHERE set_id = ?',
        [setId],
      );
      debugPrint('Bộ thẻ $setId đã được đánh dấu là đồng bộ.');
    } catch (e, stackTrace) {
      debugPrint('Lỗi đánh dấu bộ thẻ là đồng bộ: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> deleteFlashcardSet(String setId) async {
    final db = await database;
    try {
      db.execute('DELETE FROM flashcards WHERE set_id = ?', [setId]);
      db.execute('DELETE FROM flashcard_sets WHERE set_id = ?', [setId]);
      debugPrint('Bộ thẻ $setId đã được xóa thành công.');
    } catch (e, stackTrace) {
      debugPrint('Lỗi xóa bộ thẻ $setId: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      db.dispose();
      _db = null;
      debugPrint('Cơ sở dữ liệu đã được đóng.');
    }
  }
}