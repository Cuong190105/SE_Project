import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:eng_dictionary/database_SQLite/database_helper.dart';
import '../database/db_connection.dart';
import '../models/user.dart';
import 'package:mysql1/mysql1.dart';

class AuthService {
  final DatabaseHelper localDatabase = DatabaseHelper.instance;
  final MySqlConnection mysqlConnection = DatabaseConfig.connect;

  // Password hashing method using SHA-256
  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // Login method with two-level authentication
  Future<User?> login({
    required String username,
    required String password
  }) async {
    // Validate input
    if (username.isEmpty || password.isEmpty) {
      throw Exception('Please fill in all information');
    }

    // Hash the password
    final passwordHash = hashPassword(password);

    // Step 1: Check SQLite (offline)
    User? localUser = await localDatabase.login(username, passwordHash);
    if (localUser != null) {
      return localUser;
    }

    // Step 2: Check MySQL (online)
    try {
      final mysqlConn = await DatabaseConfig.connect();
      var results = await mysqlConn.query(
        'SELECT * FROM users WHERE username = ? AND password_hash = ?', 
        [username, passwordHash]
      );

      if (results.isNotEmpty) {
        var row = results.first;
        User mysqlUser = User(
          id: row['id'],
          username: row['username'],
          email: row['email'],
          passwordHash: row['password_hash'],
          isSynced: true
        );

        // Save to SQLite for offline use
        await localDatabase.createUser(mysqlUser);
        return mysqlUser;
      }
    } catch (e) {
      print('MySQL Login Error: $e');
    }

    // Login failed
    return null;
  }

  // User registration method with MySQL synchronization
  Future<User?> register({
    required String username,
    required String email,
    required String password
  }) async {
    // Validate input
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception('Please fill in all information');
    }

    // Check if user already exists
    final localUserExists = await localDatabase.checkUserExists(username, email);
    
    try {
      final mysqlConn = await DatabaseConfig.connect();
      var mysqlCheck = await mysqlConn.query(
        'SELECT * FROM users WHERE username = ? OR email = ?', 
        [username, email]
      );

      if (localUserExists || mysqlCheck.isNotEmpty) {
        throw Exception('Username or email already exists');
      }

      // Create new user
      final user = User(
        username: username,
        email: email,
        passwordHash: hashPassword(password),
        isSynced: false
      );

      // Save to SQLite
      final localUser = await localDatabase.createUser(user);

      // Save to MySQL
      await mysqlConn.query(
        'INSERT INTO users (username, email, password_hash, is_synced, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)',
        [
          localUser.username,
          localUser.email,
          localUser.passwordHash,
          0,
          localUser.createdAt.toIso8601String(),
          localUser.updatedAt.toIso8601String()
        ]
      );

      return localUser;
    } catch (e) {
      print('Registration Error: $e');
      rethrow;
    }
  }
}