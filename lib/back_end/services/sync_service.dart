import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eng_dictionary/database_SQLite/database_helper.dart';
import '../models/user.dart';

class SyncService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final String _serverUrl = 'https://yourdictionaryapp.com/api'; // Thay đổi URL phù hợp

  // Đồng bộ dữ liệu người dùng
  Future<void> syncUserData(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$_serverUrl/sync-user'),
        body: jsonEncode(user.toMap()),
        headers: {'Content-Type': 'application/json'}
      );

      if (response.statusCode == 200) {
        // Cập nhật trạng thái đồng bộ
        await _updateUserSyncStatus(user);
      } else {
        throw Exception('Đồng bộ người dùng thất bại');
      }
    } catch (e) {
      print('Lỗi đồng bộ: $e');
    }
  }

  // Cập nhật trạng thái đồng bộ
  Future<void> _updateUserSyncStatus(User user) async {
    final db = await _databaseHelper.database;
    await db.update(
      'users', 
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [user.id]
    );
  }

  // Lấy các bản ghi chưa được đồng bộ
  Future<List<User>> getUnsyncedUsers() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'users', 
      where: 'is_synced = ?', 
      whereArgs: [0]
    );

    return maps.map((map) => User.fromMap(map)).toList();
  }

  // Đồng bộ tự động
  Future<void> autoSync() async {
    final unsyncedUsers = await getUnsyncedUsers();
    for (var user in unsyncedUsers) {
      await syncUserData(user);
    }
  }
}