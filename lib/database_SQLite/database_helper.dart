import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:eng_dictionary/screens_phone/flashcard/flashcard_models.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  Database? _db;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('flashcards.db');
    return _db!;
  }

  Future<Database> _initDB(String fileName) async {
    debugPrint('Initializing database: $fileName');
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, fileName);
      final db = sqlite3.open(path);

      debugPrint('Creating tables...');
      // Tạo bảng
      db.execute('''
        CREATE TABLE IF NOT EXISTS flashcard_sets (
          set_id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          color INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          is_synced INTEGER NOT NULL DEFAULT 0
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

      debugPrint('Checking for sample data...');
      // Kiểm tra nếu bảng flashcard_sets trống, chèn dữ liệu mẫu
      final result = db.select('SELECT COUNT(*) as count FROM flashcard_sets');
      if (result.first['count'] == 0) {
        debugPrint('Inserting sample flashcard sets...');
        await _insertSampleFlashcardSets(db);
      } else {
        debugPrint('Sample data not needed, database already has sets.');
      }

      debugPrint('Database initialization complete.');
      return db;
    } catch (e, stackTrace) {
      debugPrint('Error initializing database: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> _insertSampleFlashcardSets(Database db) async {
    try {
      // Sử dụng transaction để tối ưu hóa chèn nhiều bản ghi
      db.execute('BEGIN TRANSACTION');

      final now = DateTime.now().toIso8601String();

      // Kiểm tra xem bộ mẫu đã tồn tại chưa
      final existingSets = db.select('SELECT set_id FROM flashcard_sets WHERE set_id IN (?, ?)', ['animals_001', 'music_001']);
      final existingSetIds = existingSets.map((row) => row['set_id'] as String).toSet();

      if (!existingSetIds.contains('animals_001')) {
        // Bộ mẫu 1: Động vật
        debugPrint('Inserting Animals set...');
        db.execute('''
          INSERT INTO flashcard_sets (set_id, name, description, color, created_at, updated_at, is_synced)
          VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', [
          'animals_001',
          'Động vật',
          'Từ vựng về các loài động vật',
          Colors.blue.shade700.value,
          now,
          now,
          0
        ]);

        final animalCards = [
          {'id': 'animal_001', 'front': 'Cat', 'back': 'Mèo'},
          {'id': 'animal_002', 'front': 'Dog', 'back': 'Chó'},
          {'id': 'animal_003', 'front': 'Elephant', 'back': 'Voi'},
          {'id': 'animal_004', 'front': 'Tiger', 'back': 'Hổ'},
          {'id': 'animal_005', 'front': 'Lion', 'back': 'Sư tử'},
          {'id': 'animal_006', 'front': 'Bear', 'back': 'Gấu'},
          {'id': 'animal_007', 'front': 'Wolf', 'back': 'Sói'},
          {'id': 'animal_008', 'front': 'Fox', 'back': 'Cáo'},
          {'id': 'animal_009', 'front': 'Deer', 'back': 'Nai'},
          {'id': 'animal_010', 'front': 'Monkey', 'back': 'Khỉ'},
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
        // Bộ mẫu 2: Âm nhạc
        debugPrint('Inserting Music set...');
        db.execute('''
          INSERT INTO flashcard_sets (set_id, name, description, color, created_at, updated_at, is_synced)
          VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', [
          'music_001',
          'Âm nhạc',
          'Thuật ngữ âm nhạc cơ bản',
          Colors.purple.shade700.value,
          now,
          now,
          0
        ]);

        final musicCards = [
          {'id': 'music_001', 'front': 'Note', 'back': 'Nốt nhạc'},
          {'id': 'music_002', 'front': 'Chord', 'back': 'Hợp âm'},
          {'id': 'music_003', 'front': 'Rhythm', 'back': 'Nhịp điệu'},
          {'id': 'music_004', 'front': 'Melody', 'back': 'Giai điệu'},
          {'id': 'music_005', 'front': 'Harmony', 'back': 'Hòa âm'},
          {'id': 'music_006', 'front': 'Tempo', 'back': 'Nhịp độ'},
          {'id': 'music_007', 'front': 'Pitch', 'back': 'Cao độ'},
          {'id': 'music_008', 'front': 'Scale', 'back': 'Gam'},
          {'id': 'music_009', 'front': 'Key', 'back': 'Tông'},
          {'id': 'music_010', 'front': 'Beat', 'back': 'Phách'},
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
      debugPrint('Sample flashcard sets inserted successfully.');
    } catch (e, stackTrace) {
      db.execute('ROLLBACK');
      debugPrint('Error inserting sample flashcard sets: $e\n$stackTrace');
      rethrow;
    }
  }

  // Lưu flashcard set
  Future<void> insertFlashcardSet(FlashcardSet set) async {
    final db = await database;
    try {
      db.execute('''
        INSERT OR REPLACE INTO flashcard_sets (set_id, name, description, color, created_at, updated_at, is_synced)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      ''', [
        set.id,
        set.name,
        set.description,
        set.color.value,
        set.createdAt.toIso8601String(),
        set.updatedAt.toIso8601String(),
        set.isSynced ? 1 : 0,
      ]);

      // Xóa thẻ cũ của bộ này
      db.execute('DELETE FROM flashcards WHERE set_id = ?', [set.id]);

      // Thêm thẻ mới
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
      debugPrint('Flashcard set ${set.id} inserted successfully.');
    } catch (e, stackTrace) {
      debugPrint('Error inserting flashcard set ${set.id}: $e\n$stackTrace');
      rethrow;
    }
  }

  // Lấy tất cả flashcard sets
  Future<List<FlashcardSet>> getFlashcardSets() async {
    final db = await database;
    debugPrint('Fetching all flashcard sets...');
    try {
      final setRows = db.select('SELECT * FROM flashcard_sets');
      List<FlashcardSet> sets = [];

      for (var setRow in setRows) {
        final cardRows = db.select(
          'SELECT * FROM flashcards WHERE set_id = ?',
          [setRow['set_id']],
        );

        sets.add(FlashcardSet(
          id: setRow['set_id'] as String,
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
        ));
      }

      debugPrint('Fetched ${sets.length} flashcard sets.');
      return sets;
    } catch (e, stackTrace) {
      debugPrint('Error fetching flashcard sets: $e\n$stackTrace');
      rethrow;
    }
  }

  // Lấy các bộ chưa đồng bộ
  Future<List<FlashcardSet>> getUnsyncedSets() async {
    final db = await database;
    debugPrint('Fetching unsynced flashcard sets...');
    try {
      final setRows = db.select('SELECT * FROM flashcard_sets WHERE is_synced = 0');
      List<FlashcardSet> sets = [];

      for (var setRow in setRows) {
        final cardRows = db.select(
          'SELECT * FROM flashcards WHERE set_id = ?',
          [setRow['set_id']],
        );

        sets.add(FlashcardSet(
          id: setRow['set_id'] as String,
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
        ));
      }

      debugPrint('Fetched ${sets.length} unsynced flashcard sets.');
      return sets;
    } catch (e, stackTrace) {
      debugPrint('Error fetching unsynced flashcard sets: $e\n$stackTrace');
      rethrow;
    }
  }

  // Đánh dấu bộ đã đồng bộ
  Future<void> markSetAsSynced(String setId) async {
    final db = await database;
    debugPrint('Marking set $setId as synced...');
    try {
      db.execute(
        'UPDATE flashcard_sets SET is_synced = 1 WHERE set_id = ?',
        [setId],
      );
      debugPrint('Set $setId marked as synced.');
    } catch (e, stackTrace) {
      debugPrint('Error marking set $setId as synced: $e\n$stackTrace');
      rethrow;
    }
  }

  // Xóa flashcard set
  Future<void> deleteFlashcardSet(String setId) async {
    final db = await database;
    debugPrint('Deleting flashcard set $setId...');
    try {
      db.execute('DELETE FROM flashcards WHERE set_id = ?', [setId]);
      db.execute('DELETE FROM flashcard_sets WHERE set_id = ?', [setId]);
      debugPrint('Flashcard set $setId deleted.');
    } catch (e, stackTrace) {
      debugPrint('Error deleting flashcard set $setId: $e\n$stackTrace');
      rethrow;
    }
  }

  // Xóa flashcard
  Future<void> deleteFlashcard(String cardId) async {
    final db = await database;
    debugPrint('Deleting flashcard $cardId...');
    try {
      db.execute('DELETE FROM flashcards WHERE id = ?', [cardId]);
      debugPrint('Flashcard $cardId deleted.');
    } catch (e, stackTrace) {
      debugPrint('Error deleting flashcard $cardId: $e\n$stackTrace');
      rethrow;
    }
  }

  // Đóng cơ sở dữ liệu
  Future<void> close() async {
    final db = await database;
    debugPrint('Closing database...');
    try {
      db.dispose();
      _db = null;
      debugPrint('Database closed.');
    } catch (e, stackTrace) {
      debugPrint('Error closing database: $e\n$stackTrace');
      rethrow;
    }
  }
}