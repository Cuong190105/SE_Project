import 'package:mysql1/mysql1.dart';
import '../database/db_connection.dart';
import '../models/user.dart';

class UserService {
  final DBConnection _db = DBConnection();

  Future<int> createUser(User user) async {
    final conn = await _db.connection;
    var result = await conn.query(
      'INSERT INTO Users (email, passwordHash, fullName, role) VALUES (?, ?, ?, ?)',
      [user.email, user.passwordHash, user.fullName, user.role],
    );
    return result.insertId!;
  }

  Future<User?> getUserByEmail(String email) async {
    final conn = await _db.connection;
    var results = await conn.query('SELECT * FROM Users WHERE email = ?', [email]);

    if (results.isNotEmpty) {
      var row = results.first;
      return User(
        userID: row['userID'],
        email: row['email'],
        passwordHash: row['passwordHash'],
        fullName: row['fullName'],
        role: row['role'],
      );
    }
    return null;
  }
}
