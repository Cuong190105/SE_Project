import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../back_end/models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Khởi tạo và kết nối CSDL SQLite
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dictionary_app.db');
    return _database!;
  }

  // Tạo CSDL và các bảng cần thiết
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path, 
      version: 1, 
      onCreate: _createDB
    );
  }

  // Tạo các bảng cho ứng dụng
  Future<void> _createDB(Database db, int version) async {
    // Tạo bảng users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Tạo bảng từ vựng
    await db.execute('''
      CREATE TABLE vocabularies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        word TEXT NOT NULL,
        meaning TEXT NOT NULL,
        example TEXT,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Tạo bảng flashcards
    await db.execute('''
      CREATE TABLE flashcards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        name TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  // Thêm người dùng mới
  Future<User> createUser(User user) async {
    final db = await database;
    final id = await db.insert('users', user.toMap());
    return user.copyWith(id: id);
  }

  // Kiểm tra đăng nhập
  Future<User?> login(String username, String passwordHash) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'username = ? AND password_hash = ?',
      whereArgs: [username, passwordHash]
    );

    return maps.isNotEmpty ? User.fromMap(maps.first) : null;
  }

  // Kiểm tra tồn tại người dùng
  Future<bool> checkUserExists(String username, String email) async {
    final db = await database;
    final usernameCheck = await db.query(
      'users', 
      where: 'username = ?', 
      whereArgs: [username]
    );
    final emailCheck = await db.query(
      'users', 
      where: 'email = ?', 
      whereArgs: [email]
    );

    return usernameCheck.isNotEmpty || emailCheck.isNotEmpty;
  }
}