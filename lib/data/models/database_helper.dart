import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;
import '../models/flashcard.dart';
import '../models/flashcard_set.dart';
import '../models/flashcard_manager.dart';
import 'package:uuid/uuid.dart';
import 'word_set.dart';
import 'meaning.dart';

// Định nghĩa các lớp mô hình cho từ vựng
class Word {
  final String wordId;
  final String userEmail;
  final String word;
  final String partOfSpeech;
  final String? usIpa;
  final String? ukIpa;
  final String definition;
  final List<String> examples;
  final List<Synonym> synonyms;
  final List<Antonym> antonyms;
  final List<FamilyWord> family;
  final List<Phrase> phrases;
  final List<Media> media;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final bool isDeleted;

  Word({
    required this.wordId,
    required this.userEmail,
    required this.word,
    required this.partOfSpeech,
    this.usIpa,
    this.ukIpa,
    required this.definition,
    this.examples = const [],
    this.synonyms = const [],
    this.antonyms = const [],
    this.family = const [],
    this.phrases = const [],
    this.media = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.isDeleted = false,
  });
}

class Synonym {
  final String synonymId;
  final String synonymWordId;

  Synonym({
    required this.synonymId,
    required this.synonymWordId,
  });
}

class Antonym {
  final String antonymId;
  final String antonymWordId;

  Antonym({
    required this.antonymId,
    required this.antonymWordId,
  });
}

class FamilyWord {
  final String familyId;
  final String familyWord;

  FamilyWord({
    required this.familyId,
    required this.familyWord,
  });
}

class Phrase {
  final String phraseId;
  final String phrase;

  Phrase({
    required this.phraseId,
    required this.phrase,
  });
}

class Media {
  final String mediaId;
  final String type;
  final String filePath;

  Media({
    required this.mediaId,
    required this.type,
    required this.filePath,
  });
}

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
      _db = await _initDB('eng_dictionary.db');
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
          is_deleted INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (set_id) REFERENCES flashcard_sets (set_id)
        )
      ''');

      db.execute('''
        CREATE TABLE IF NOT EXISTS words (
          word_id TEXT PRIMARY KEY,
          user_email TEXT NOT NULL,
          word TEXT NOT NULL,
          part_of_speech TEXT NOT NULL,
          us_ipa TEXT,
          uk_ipa TEXT,
          definition TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          is_synced INTEGER NOT NULL DEFAULT 0,
          is_deleted INTEGER NOT NULL DEFAULT 0
        )
      ''');

      db.execute('''
        CREATE TABLE IF NOT EXISTS synonyms (
          synonym_id TEXT PRIMARY KEY,
          word_id TEXT NOT NULL,
          synonym_word_id TEXT NOT NULL,
          FOREIGN KEY (word_id) REFERENCES words (word_id)
        )
      ''');

      db.execute('''
        CREATE TABLE IF NOT EXISTS antonyms (
          antonym_id TEXT PRIMARY KEY,
          word_id TEXT NOT NULL,
          antonym_word_id TEXT NOT NULL,
          FOREIGN KEY (word_id) REFERENCES words (word_id)
        )
      ''');

      db.execute('''
        CREATE TABLE IF NOT EXISTS family (
          family_id TEXT PRIMARY KEY,
          word_id TEXT NOT NULL,
          family_word TEXT NOT NULL,
          FOREIGN KEY (word_id) REFERENCES words (word_id)
        )
      ''');

      db.execute('''
        CREATE TABLE IF NOT EXISTS phrases (
          phrase_id TEXT PRIMARY KEY,
          word_id TEXT NOT NULL,
          phrase TEXT NOT NULL,
          FOREIGN KEY (word_id) REFERENCES words (word_id)
        )
      ''');

      db.execute('''
        CREATE TABLE IF NOT EXISTS media (
          media_id TEXT PRIMARY KEY,
          word_id TEXT NOT NULL,
          type TEXT NOT NULL,
          file_path TEXT NOT NULL,
          FOREIGN KEY (word_id) REFERENCES words (word_id)
        )
      ''');

      db.execute('''
        CREATE TABLE IF NOT EXISTS examples (
          example_id TEXT PRIMARY KEY,
          word_id TEXT NOT NULL,
          example TEXT NOT NULL,
          FOREIGN KEY (word_id) REFERENCES words (word_id)
        )
      ''');

      db.execute('CREATE INDEX IF NOT EXISTS idx_flashcard_sets_user_email ON flashcard_sets(user_email)');
      db.execute('CREATE INDEX IF NOT EXISTS idx_flashcards_set_id ON flashcards(set_id)');
      db.execute('CREATE INDEX IF NOT EXISTS idx_words_user_email ON words(user_email)');
      db.execute('CREATE INDEX IF NOT EXISTS idx_synonyms_word_id ON synonyms(word_id)');
      db.execute('CREATE INDEX IF NOT EXISTS idx_antonyms_word_id ON antonyms(word_id)');
      db.execute('CREATE INDEX IF NOT EXISTS idx_family_word_id ON family(word_id)');
      db.execute('CREATE INDEX IF NOT EXISTS idx_phrases_word_id ON phrases(word_id)');
      db.execute('CREATE INDEX IF NOT EXISTS idx_media_word_id ON media(word_id)');
      db.execute('CREATE INDEX IF NOT EXISTS idx_examples_word_id ON examples(word_id)');

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
            INSERT INTO flashcards (id, set_id, front, back, is_learned, is_deleted)
            VALUES (?, ?, ?, ?, ?, ?)
          ''', [
            card['id'],
            'animals_001',
            card['front'],
            card['back'],
            0,
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
            INSERT INTO flashcards (id, set_id, front, back, is_learned, is_deleted)
            VALUES (?, ?, ?, ?, ?, ?)
          ''', [
            card['id'],
            'music_001',
            card['front'],
            card['back'],
            0,
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

  Future<void> _insertSampleWords(sqlite3.Database db) async {
    try {
      db.execute('BEGIN TRANSACTION');
      final now = DateTime.now().toIso8601String();
      final uuid = Uuid();

      final sampleWords = [
        {
          'word_id': 'word_001',
          'word': 'Big',
          'part_of_speech': 'adjective',
          'us_ipa': '/bɪɡ/',
          'uk_ipa': '/bɪɡ/',
          'definition': 'Having a large size',
          'examples': ['The elephant is big.', 'This is a big house.'],
          'synonyms': ['large', 'huge'],
          'antonyms': ['small', 'tiny'],
          'family': ['bigger', 'biggest'],
          'phrases': ['big deal', 'big picture']
        },
        {
          'word_id': 'word_002',
          'word': 'Fast',
          'part_of_speech': 'adjective',
          'us_ipa': '/fæst/',
          'uk_ipa': '/fɑːst/',
          'definition': 'Moving or capable of moving at high speed',
          'examples': ['The car is fast.', 'He runs very fast.'],
          'synonyms': ['quick', 'swift'],
          'antonyms': ['slow', 'sluggish'],
          'family': ['faster', 'fastest'],
          'phrases': ['fast track', 'fast forward']
        }
      ];

      for (var wordData in sampleWords) {
        db.execute('''
          INSERT INTO words (
            word_id, user_email, word, part_of_speech, us_ipa, uk_ipa, definition, created_at, updated_at, is_synced, is_deleted
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
          wordData['word_id'],
          'sample@example.com',
          wordData['word'],
          wordData['part_of_speech'],
          wordData['us_ipa'],
          wordData['uk_ipa'],
          wordData['definition'],
          now,
          now,
          1,
          0
        ]);

        for (var example in wordData['examples'] as List<String>) {
          db.execute('''
            INSERT INTO examples (example_id, word_id, example)
            VALUES (?, ?, ?)
          ''', [uuid.v4(), wordData['word_id'], example]);
        }

        for (var synonym in wordData['synonyms'] as List<String>) {
          db.execute('''
            INSERT INTO synonyms (synonym_id, word_id, synonym_word_id)
            VALUES (?, ?, ?)
          ''', [uuid.v4(), wordData['word_id'], synonym]);
        }

        for (var antonym in wordData['antonyms'] as List<String>) {
          db.execute('''
            INSERT INTO antonyms (antonym_id, word_id, antonym_word_id)
            VALUES (?, ?, ?)
          ''', [uuid.v4(), wordData['word_id'], antonym]);
        }

        for (var familyWord in wordData['family'] as List<String>) {
          db.execute('''
            INSERT INTO family (family_id, word_id, family_word)
            VALUES (?, ?, ?)
          ''', [uuid.v4(), wordData['word_id'], familyWord]);
        }

        for (var phrase in wordData['phrases'] as List<String>) {
          db.execute('''
            INSERT INTO phrases (phrase_id, word_id, phrase)
            VALUES (?, ?, ?)
          ''', [uuid.v4(), wordData['word_id'], phrase]);
        }
      }

      db.execute('COMMIT');
      debugPrint('Chèn dữ liệu mẫu từ vựng thành công.');
    } catch (e, stackTrace) {
      db.execute('ROLLBACK');
      debugPrint('Lỗi chèn dữ liệu mẫu từ vựng: $e\n$stackTrace');
      throw Exception('Không thể chèn dữ liệu mẫu từ vựng.');
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

  Future<void> ensureSampleWords() async {
    final db = await database;
    try {
      final sampleCount = db.select('SELECT COUNT(*) as count FROM words WHERE is_synced = 1');
      if (sampleCount.first['count'] == 0) {
        debugPrint('Chèn dữ liệu mẫu từ vựng vì không tìm thấy...');
        await _insertSampleWords(db);
      } else {
        debugPrint('Dữ liệu mẫu từ vựng đã tồn tại.');
      }
    } catch (e, stackTrace) {
      debugPrint('Lỗi kiểm tra dữ liệu mẫu từ vựng: $e\n$stackTrace');
      throw Exception('Không thể kiểm tra dữ liệu mẫu từ vựng.');
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

      db.execute('DELETE FROM flashcards WHERE set_id = ? AND is_deleted = 0', [set.id]);

      for (var card in set.cards) {
        db.execute('''
          INSERT OR REPLACE INTO flashcards (id, set_id, front, back, is_learned, is_deleted)
          VALUES (?, ?, ?, ?, ?, ?)
        ''', [
          card.id,
          set.id,
          card.frontContent,
          card.backContent,
          card.isLearned ? 1 : 0,
          card.isDeleted ? 1 : 0,
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
          'SELECT * FROM flashcards WHERE set_id = ? AND is_deleted = 0',
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
            isDeleted: (cardRow['is_deleted'] as int) == 1,
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
            isDeleted: (cardRow['is_deleted'] as int) == 1,
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

  Future<void> insertWord(Word word) async {
    final db = await database;
    try {
      db.execute('BEGIN TRANSACTION');

      final createdAtStr = word.createdAt.toIso8601String();
      final updatedAtStr = word.updatedAt.toIso8601String();

      db.execute('''
        INSERT OR REPLACE INTO words (
          word_id, user_email, word, part_of_speech, us_ipa, uk_ipa, definition, created_at, updated_at, is_synced, is_deleted
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        word.wordId,
        word.userEmail,
        word.word,
        word.partOfSpeech,
        word.usIpa,
        word.ukIpa,
        word.definition,
        createdAtStr,
        updatedAtStr,
        word.isSynced ? 1 : 0,
        word.isDeleted ? 1 : 0,
      ]);

      db.execute('DELETE FROM synonyms WHERE word_id = ?', [word.wordId]);
      db.execute('DELETE FROM antonyms WHERE word_id = ?', [word.wordId]);
      db.execute('DELETE FROM family WHERE word_id = ?', [word.wordId]);
      db.execute('DELETE FROM phrases WHERE word_id = ?', [word.wordId]);
      db.execute('DELETE FROM media WHERE word_id = ?', [word.wordId]);
      db.execute('DELETE FROM examples WHERE word_id = ?', [word.wordId]);

      for (var synonym in word.synonyms) {
        db.execute('''
          INSERT INTO synonyms (synonym_id, word_id, synonym_word_id)
          VALUES (?, ?, ?)
        ''', [
          synonym.synonymId,
          word.wordId,
          synonym.synonymWordId,
        ]);
      }

      for (var antonym in word.antonyms) {
        db.execute('''
          INSERT INTO antonyms (antonym_id, word_id, antonym_word_id)
          VALUES (?, ?, ?)
        ''', [
          antonym.antonymId,
          word.wordId,
          antonym.antonymWordId,
        ]);
      }

      for (var familyWord in word.family) {
        db.execute('''
          INSERT INTO family (family_id, word_id, family_word)
          VALUES (?, ?, ?)
        ''', [
          familyWord.familyId,
          word.wordId,
          familyWord.familyWord,
        ]);
      }

      for (var phrase in word.phrases) {
        db.execute('''
          INSERT INTO phrases (phrase_id, word_id, phrase)
          VALUES (?, ?, ?)
        ''', [
          phrase.phraseId,
          word.wordId,
          phrase.phrase,
        ]);
      }

      for (var media in word.media) {
        db.execute('''
          INSERT INTO media (media_id, word_id, type, file_path)
          VALUES (?, ?, ?, ?)
        ''', [
          media.mediaId,
          word.wordId,
          media.type,
          media.filePath,
        ]);
      }

      for (var example in word.examples) {
        db.execute('''
          INSERT INTO examples (example_id, word_id, example)
          VALUES (?, ?, ?)
        ''', [
          Uuid().v4(),
          word.wordId,
          example,
        ]);
      }

      db.execute('COMMIT');
      debugPrint('Từ vựng ${word.wordId} đã được lưu thành công.');
    } catch (e, stackTrace) {
      db.execute('ROLLBACK');
      debugPrint('Lỗi lưu từ vựng ${word.wordId}: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<List<Word>> getWords() async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('user_email') ?? 'unknown_user@example.com';
    debugPrint('Lấy danh sách từ vựng cho người dùng: $userEmail...');

    try {
      final wordRows = db.select(
        '''
        SELECT w.*, 
               s.synonym_id, s.synonym_word_id,
               a.antonym_id, a.antonym_word_id,
               f.family_id, f.family_word,
               p.phrase_id, p.phrase,
               med.media_id, med.type, med.file_path,
               e.example_id, e.example
        FROM words w
        LEFT JOIN synonyms s ON w.word_id = s.word_id
        LEFT JOIN antonyms a ON w.word_id = a.word_id
        LEFT JOIN family f ON w.word_id = f.word_id
        LEFT JOIN phrases p ON w.word_id = p.word_id
        LEFT JOIN media med ON w.word_id = med.word_id
        LEFT JOIN examples e ON w.word_id = e.word_id
        WHERE w.user_email = ? AND w.is_deleted = 0
        ''',
        [userEmail],
      );

      Map<String, Word> wordMap = {};

      for (var row in wordRows) {
        final wordId = row['word_id'] as String;

        if (!wordMap.containsKey(wordId)) {
          wordMap[wordId] = Word(
            wordId: wordId,
            userEmail: row['user_email'] as String,
            word: row['word'] as String,
            partOfSpeech: row['part_of_speech'] as String,
            usIpa: row['us_ipa'] as String?,
            ukIpa: row['uk_ipa'] as String?,
            definition: row['definition'] as String,
            examples: [],
            synonyms: [],
            antonyms: [],
            family: [],
            phrases: [],
            media: [],
            createdAt: DateTime.parse(row['created_at'] as String),
            updatedAt: DateTime.parse(row['updated_at'] as String),
            isSynced: (row['is_synced'] as int) == 1,
            isDeleted: (row['is_deleted'] as int) == 1,
          );
        }

        final word = wordMap[wordId]!;

        if (row['synonym_id'] != null) {
          word.synonyms.add(Synonym(
            synonymId: row['synonym_id'] as String,
            synonymWordId: row['synonym_word_id'] as String,
          ));
        }

        if (row['antonym_id'] != null) {
          word.antonyms.add(Antonym(
            antonymId: row['antonym_id'] as String,
            antonymWordId: row['antonym_word_id'] as String,
          ));
        }

        if (row['family_id'] != null) {
          word.family.add(FamilyWord(
            familyId: row['family_id'] as String,
            familyWord: row['family_word'] as String,
          ));
        }

        if (row['phrase_id'] != null) {
          word.phrases.add(Phrase(
            phraseId: row['phrase_id'] as String,
            phrase: row['phrase'] as String,
          ));
        }

        if (row['media_id'] != null) {
          word.media.add(Media(
            mediaId: row['media_id'] as String,
            type: row['type'] as String,
            filePath: row['file_path'] as String,
          ));
        }

        if (row['example_id'] != null) {
          word.examples.add(row['example'] as String);
        }
      }

      final words = wordMap.values.toList();
      debugPrint('Đã lấy ${words.length} từ vựng cho người dùng: $userEmail.');
      return words;
    } catch (e, stackTrace) {
      debugPrint('Lỗi lấy danh sách từ vựng: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<List<Word>> getUnsyncedWords() async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('user_email');
    if (userEmail == null) {
      debugPrint('Không tìm thấy email người dùng.');
      return [];
    }
    debugPrint('Lấy danh sách từ vựng chưa đồng bộ cho người dùng: $userEmail...');

    try {
      final wordRows = db.select(
        '''
        SELECT w.*, 
               s.synonym_id, s.synonym_word_id,
               a.antonym_id, a.antonym_word_id,
               f.family_id, f.family_word,
               p.phrase_id, p.phrase,
               med.media_id, med.type, med.file_path,
               e.example_id, e.example
        FROM words w
        LEFT JOIN synonyms s ON w.word_id = s.word_id
        LEFT JOIN antonyms a ON w.word_id = a.word_id
        LEFT JOIN family f ON w.word_id = f.word_id
        LEFT JOIN phrases p ON w.word_id = p.word_id
        LEFT JOIN media med ON w.word_id = med.word_id
        LEFT JOIN examples e ON w.word_id = e.word_id
        WHERE w.user_email = ? AND w.is_synced = 0 AND w.is_deleted = 0
        ''',
        [userEmail],
      );

      Map<String, Word> wordMap = {};

      for (var row in wordRows) {
        final wordId = row['word_id'] as String;

        if (!wordMap.containsKey(wordId)) {
          wordMap[wordId] = Word(
            wordId: wordId,
            userEmail: row['user_email'] as String,
            word: row['word'] as String,
            partOfSpeech: row['part_of_speech'] as String,
            usIpa: row['us_ipa'] as String?,
            ukIpa: row['uk_ipa'] as String?,
            definition: row['definition'] as String,
            examples: [],
            synonyms: [],
            antonyms: [],
            family: [],
            phrases: [],
            media: [],
            createdAt: DateTime.parse(row['created_at'] as String),
            updatedAt: DateTime.parse(row['updated_at'] as String),
            isSynced: (row['is_synced'] as int) == 1,
            isDeleted: (row['is_deleted'] as int) == 1,
          );
        }

        final word = wordMap[wordId]!;

        if (row['synonym_id'] != null) {
          word.synonyms.add(Synonym(
            synonymId: row['synonym_id'] as String,
            synonymWordId: row['synonym_word_id'] as String,
          ));
        }

        if (row['antonym_id'] != null) {
          word.antonyms.add(Antonym(
            antonymId: row['antonym_id'] as String,
            antonymWordId: row['antonym_word_id'] as String,
          ));
        }

        if (row['family_id'] != null) {
          word.family.add(FamilyWord(
            familyId: row['family_id'] as String,
            familyWord: row['family_word'] as String,
          ));
        }

        if (row['phrase_id'] != null) {
          word.phrases.add(Phrase(
            phraseId: row['phrase_id'] as String,
            phrase: row['phrase'] as String,
          ));
        }

        if (row['media_id'] != null) {
          word.media.add(Media(
            mediaId: row['media_id'] as String,
            type: row['type'] as String,
            filePath: row['file_path'] as String,
          ));
        }

        if (row['example_id'] != null) {
          word.examples.add(row['example'] as String);
        }
      }

      final words = wordMap.values.toList();
      debugPrint('Đã lấy ${words.length} từ vựng chưa đồng bộ cho người dùng: $userEmail.');
      return words;
    } catch (e, stackTrace) {
      debugPrint('Lỗi lấy danh sách từ vựng chưa đồng bộ: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> markWordAsSynced(String wordId) async {
    final db = await database;
    try {
      db.execute(
        'UPDATE words SET is_synced = 1 WHERE word_id = ?',
        [wordId],
      );
      debugPrint('Từ vựng $wordId đã được đánh dấu là đồng bộ.');
    } catch (e, stackTrace) {
      debugPrint('Lỗi đánh dấu từ vựng là đồng bộ: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> deleteWord(String wordId) async {
    final db = await database;
    try {
      db.execute('UPDATE words SET is_deleted = 1 WHERE word_id = ?', [wordId]);
      debugPrint('Từ vựng $wordId đã được đánh dấu là xóa.');
    } catch (e, stackTrace) {
      debugPrint('Lỗi đánh dấu xóa từ vựng $wordId: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<List<WordSet>> getWordSets() async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('user_email') ?? 'unknown_user@example.com';
    debugPrint('Lấy danh sách bộ từ cho người dùng: $userEmail và bộ mẫu...');

    try {
      final wordRows = db.select(
        '''
        SELECT w.*, 
               s.synonym_id, s.synonym_word_id,
               a.antonym_id, a.antonym_word_id,
               f.family_id, f.family_word,
               p.phrase_id, p.phrase,
               med.media_id, med.type, med.file_path,
               e.example_id, e.example
        FROM words w
        LEFT JOIN synonyms s ON w.word_id = s.word_id
        LEFT JOIN antonyms a ON w.word_id = a.word_id
        LEFT JOIN family f ON w.word_id = f.word_id
        LEFT JOIN phrases p ON w.word_id = p.word_id
        LEFT JOIN media med ON w.word_id = med.word_id
        LEFT JOIN examples e ON w.word_id = e.word_id
        WHERE w.user_email = ? OR w.is_synced = 1
        ''',
        [userEmail],
      );

      Map<String, WordSet> wordSetMap = {};

      for (var row in wordRows) {
        final wordId = row['word_id'] as String;

        if (!wordSetMap.containsKey(wordId)) {
          final meaning = Meaning(
            meaningId: wordId,
            definition: row['definition'] as String,
            partOfSpeech: row['part_of_speech'] as String,
            us_phonetic: row['us_ipa'] as String? ?? '',
            uk_phonetic: row['uk_ipa'] as String? ?? '',
            example1: row['example'] as String? ?? '',
            example2: '',
          );

          wordSetMap[wordId] = WordSet(
            id: wordId,
            userEmail: row['user_email'] as String,
            word: row['word'] as String,
            meanings: [meaning],
            synonyms: '',
            antonyms: '',
            family: '',
            phrases: '',
            createdAt: DateTime.parse(row['created_at'] as String),
            updatedAt: DateTime.parse(row['updated_at'] as String),
            isSynced: (row['is_synced'] as int) == 1,
            isSample: false,
            deleted: (row['is_deleted'] as int) == 1,
          );
        }

        final wordSet = wordSetMap[wordId]!;

        if (row['synonym_id'] != null) {
          wordSet.synonyms += (wordSet.synonyms.isEmpty ? '' : ', ') + (row['synonym_word_id'] as String);
        }

        if (row['antonym_id'] != null) {
          wordSet.antonyms += (wordSet.antonyms.isEmpty ? '' : ', ') + (row['antonym_word_id'] as String);
        }

        if (row['family_id'] != null) {
          wordSet.family += (wordSet.family.isEmpty ? '' : ', ') + (row['family_word'] as String);
        }

        if (row['phrase_id'] != null) {
          wordSet.phrases += (wordSet.phrases.isEmpty ? '' : ', ') + (row['phrase'] as String);
        }

        if (row['media_id'] != null && row['type'] == 'image') {
          final file = File(row['file_path'] as String);
          if (await file.exists()) {
            wordSet.meanings[0].image = await file.readAsBytes();
          }
        }
      }

      final wordSets = wordSetMap.values.toList();
      debugPrint('Đã lấy ${wordSets.length} bộ từ cho người dùng: $userEmail.');
      return wordSets;
    } catch (e, stackTrace) {
      debugPrint('Lỗi lấy danh sách bộ từ: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> insertWordSets(WordSet wordSet) async {
    final db = await database;
    try {
      db.execute('BEGIN TRANSACTION');

      final createdAtStr = wordSet.createdAt.toIso8601String();
      final updatedAtStr = wordSet.updatedAt.toIso8601String();

      final meaning = wordSet.meanings.isNotEmpty ? wordSet.meanings[0] : Meaning(meaningId: wordSet.id);
      final word = Word(
        wordId: wordSet.id,
        userEmail: wordSet.userEmail,
        word: wordSet.word,
        partOfSpeech: meaning.partOfSpeech,
        usIpa: meaning.us_phonetic,
        ukIpa: meaning.uk_phonetic,
        definition: meaning.definition,
        examples: [meaning.example1, meaning.example2].where((e) => e.isNotEmpty).toList(),
        synonyms: wordSet.synonyms.isNotEmpty
            ? wordSet.synonyms.split(',').map((s) => Synonym(
          synonymId: Uuid().v4(),
          synonymWordId: s.trim(),
        )).toList()
            : [],
        antonyms: wordSet.antonyms.isNotEmpty
            ? wordSet.antonyms.split(',').map((a) => Antonym(
          antonymId: Uuid().v4(),
          antonymWordId: a.trim(),
        )).toList()
            : [],
        family: wordSet.family.isNotEmpty
            ? wordSet.family.split(',').map((f) => FamilyWord(
          familyId: Uuid().v4(),
          familyWord: f.trim(),
        )).toList()
            : [],
        phrases: wordSet.phrases.isNotEmpty
            ? wordSet.phrases.split(',').map((p) => Phrase(
          phraseId: Uuid().v4(),
          phrase: p.trim(),
        )).toList()
            : [],
        media: meaning.image != null
            ? [
          Media(
            mediaId: Uuid().v4(),
            type: 'image',
            filePath: join((await getApplicationDocumentsDirectory()).path, 'images', '${wordSet.id}.jpg'),
          )
        ]
            : [],
        createdAt: wordSet.createdAt,
        updatedAt: wordSet.updatedAt,
        isSynced: wordSet.isSynced,
        isDeleted: wordSet.deleted,
      );

      if (meaning.image != null) {
        final file = File(word.media.isNotEmpty ? word.media[0].filePath : '');
        await file.create(recursive: true);
        await file.writeAsBytes(meaning.image!);
      }

      await insertWord(word);

      db.execute('COMMIT');
      debugPrint('Bộ từ ${wordSet.id} đã được lưu thành công.');
    } catch (e, stackTrace) {
      db.execute('ROLLBACK');
      debugPrint('Lỗi lưu bộ từ ${wordSet.id}: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<List<WordSet>> getUnsyncedWordSets() async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('user_email');
    if (userEmail == null) {
      debugPrint('Không tìm thấy email người dùng.');
      return [];
    }
    debugPrint('Lấy danh sách bộ từ chưa đồng bộ cho người dùng: $userEmail...');

    try {
      final wordRows = db.select(
        '''
        SELECT w.*, 
               s.synonym_id, s.synonym_word_id,
               a.antonym_id, a.antonym_word_id,
               f.family_id, f.family_word,
               p.phrase_id, p.phrase,
               med.media_id, med.type, med.file_path,
               e.example_id, e.example
        FROM words w
        LEFT JOIN synonyms s ON w.word_id = s.word_id
        LEFT JOIN antonyms a ON w.word_id = a.word_id
        LEFT JOIN family f ON w.word_id = f.word_id
        LEFT JOIN phrases p ON w.word_id = p.word_id
        LEFT JOIN media med ON w.word_id = med.word_id
        LEFT JOIN examples e ON w.word_id = e.word_id
        WHERE w.user_email = ? AND w.is_synced = 0 AND w.is_deleted = 0
        ''',
        [userEmail],
      );

      Map<String, WordSet> wordSetMap = {};

      for (var row in wordRows) {
        final wordId = row['word_id'] as String;

        if (!wordSetMap.containsKey(wordId)) {
          final meaning = Meaning(
            meaningId: wordId,
            definition: row['definition'] as String,
            partOfSpeech: row['part_of_speech'] as String,
            us_phonetic: row['us_ipa'] as String? ?? '',
            uk_phonetic: row['uk_ipa'] as String? ?? '',
            example1: row['example'] as String? ?? '',
            example2: '',
          );

          wordSetMap[wordId] = WordSet(
            id: wordId,
            userEmail: row[' sleevesuser_email'] as String,
            word: row['word'] as String,
            meanings: [meaning],
            synonyms: '',
            antonyms: '',
            family: '',
            phrases: '',
            createdAt: DateTime.parse(row['created_at'] as String),
            updatedAt: DateTime.parse(row['updated_at'] as String),
            isSynced: false,
            isSample: false,
            deleted: (row['is_deleted'] as int) == 1,
          );
        }

        final wordSet = wordSetMap[wordId]!;

        if (row['synonym_id'] != null) {
          wordSet.synonyms += (wordSet.synonyms.isEmpty ? '' : ', ') + (row['synonym_word_id'] as String);
        }

        if (row['antonym_id'] != null) {
          wordSet.antonyms += (wordSet.antonyms.isEmpty ? '' : ', ') + (row['antonym_word_id'] as String);
        }

        if (row['family_id'] != null) {
          wordSet.family += (wordSet.family.isEmpty ? '' : ', ') + (row['family_word'] as String);
        }

        if (row['phrase_id'] != null) {
          wordSet.phrases += (wordSet.phrases.isEmpty ? '' : ', ') + (row['phrase'] as String);
        }

        if (row['media_id'] != null && row['type'] == 'image') {
          final file = File(row['file_path'] as String);
          if (await file.exists()) {
            wordSet.meanings[0].image = await file.readAsBytes();
          }
        }
      }

      final wordSets = wordSetMap.values.toList();
      debugPrint('Đã lấy ${wordSets.length} bộ từ chưa đồng bộ cho người dùng: $userEmail.');
      return wordSets;
    } catch (e, stackTrace) {
      debugPrint('Lỗi lấy danh sách bộ từ chưa đồng bộ: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> deleteWordSets(String wordSetId) async {
    await deleteWord(wordSetId);
  }

  Future<void> markWordSetAsSynced(String wordSetId) async {
    await markWordAsSynced(wordSetId);
  }

  Future<void> close() async {
    if (_db != null) {
      _db!.dispose();
      _db = null;
      debugPrint('Cơ sở dữ liệu đã được đóng.');
    }
  }
}