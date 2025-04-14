import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // Path to the database file
  String? _dbPath;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Get the database directory path for storing the database
    final dbDir = await _getDatabasesPath();
    final path = join(dbDir, filePath);
    _dbPath = path;

    // Ensure the directory exists
    await Directory(dirname(path)).create(recursive: true);

    // Open the database
    final db = sqlite3.open(path);

    // Configure and create tables
    await _onConfigure(db);
    await _createDB(db);

    return db;
  }

  Future<String> _getDatabasesPath() async {
    // For mobile platforms, we could use path_provider
    // For this implementation, we'll use a simple approach
    return Directory.systemTemp.path;
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign key support
    db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db) async {
    // Define your initial tables here
    db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Add other tables if needed
  }

  // Generic insert method
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;

    // Build the INSERT statement
    final columns = data.keys.join(', ');
    final placeholders = data.keys.map((_) => '?').join(', ');
    final values = data.values.toList();

    // Execute the statement
    final stmt = db.prepare(
        'INSERT OR REPLACE INTO $table ($columns) VALUES ($placeholders)'
    );

    try {
      stmt.execute(values);
      final id = db.lastInsertRowId;
      return id;
    } finally {
      stmt.dispose();
    }
  }

  // Generic query method
  Future<List<Map<String, dynamic>>> query(String table, {
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;

    // Build the query
    final columnStr = columns != null ? columns.join(', ') : '*';
    var sql = 'SELECT $columnStr FROM $table';

    if (where != null) {
      sql += ' WHERE $where';
    }

    if (orderBy != null) {
      sql += ' ORDER BY $orderBy';
    }

    final stmt = db.prepare(sql);

    try {
      // Execute the query
      if (whereArgs != null && whereArgs.isNotEmpty) {
        final result = stmt.select(whereArgs);
        return _convertResultsToList(result);
      } else {
        final result = stmt.select([]);
        return _convertResultsToList(result);
      }
    } finally {
      stmt.dispose();
    }
  }

  // Helper method to convert ResultSet to List<Map<String, dynamic>>
  List<Map<String, dynamic>> _convertResultsToList(ResultSet resultSet) {
    final results = <Map<String, dynamic>>[];

    for (final row in resultSet) {
      final map = <String, dynamic>{};

      for (final column in row.keys) {
        map[column] = row[column];
      }

      results.add(map);
    }

    return results;
  }

  // Generic update method
  Future<int> update(String table, Map<String, dynamic> data, {
    required String whereClause,
    required List<dynamic> whereArgs
  }) async {
    final db = await database;

    // Build the UPDATE statement
    final setClause = data.keys.map((key) => '$key = ?').join(', ');
    final values = [...data.values, ...whereArgs];

    final sql = 'UPDATE $table SET $setClause WHERE $whereClause';
    final stmt = db.prepare(sql);

    try {
      stmt.execute(values);
      return db.getUpdatedRows(); // Returns number of rows affected
    } finally {
      stmt.dispose();
    }
  }

  // Generic delete method
  Future<int> delete(String table, {
    required String whereClause,
    required List<dynamic> whereArgs
  }) async {
    final db = await database;

    final sql = 'DELETE FROM $table WHERE $whereClause';
    final stmt = db.prepare(sql);

    try {
      stmt.execute(whereArgs);
      return db.getUpdatedRows(); // Returns number of rows affected
    } finally {
      stmt.dispose();
    }
  }

  // Close the database connection
  Future<void> close() async {
    final db = await database;
    db.dispose();
    _database = null;
  }

  // Delete the entire database
  Future<void> deleteDatabase() async {
    if (_dbPath != null) {
      final file = File(_dbPath!);
      if (await file.exists()) {
        await file.delete();
      }
      _database = null;
    }
  }
}
