import 'dart:io';
import '../database_SQLite/database_helper.dart';

void main() async {
  print('🔍 Testing SQLite3 DatabaseHelper implementation...');

  try {
    // Lấy instance từ singleton
    final dbHelper = DatabaseHelper.instance;

    // Thêm dữ liệu kiểm tra
    final testUser = {
      'username': 'test_user',
      'email': 'test@example.com',
      'created_at': DateTime.now().toIso8601String()
    };

    print('1️⃣ Inserting test user...');
    final id = await dbHelper.insert('users', testUser);
    print('✅ User inserted with ID: $id');

    // Truy vấn dữ liệu
    print('2️⃣ Querying all users...');
    final allUsers = await dbHelper.query('users');
    print('✅ Found ${allUsers.length} users:');
    for (var user in allUsers) {
      print('  👤 ${user['username']} (${user['email']})');
    }

    // Tìm kiếm theo điều kiện
    print('3️⃣ Finding user by username...');
    final foundUsers = await dbHelper.query(
        'users',
        where: 'username = ?',
        whereArgs: ['test_user']
    );
    if (foundUsers.isNotEmpty) {
      print('✅ Found user: ${foundUsers.first['username']}');
    } else {
      print('❌ User not found!');
    }

    // Cập nhật dữ liệu
    print('4️⃣ Updating user email...');
    final updatedCount = await dbHelper.update(
        'users',
        {'email': 'updated@example.com'},
        whereClause: 'username = ?',
        whereArgs: ['test_user']
    );
    print('✅ Updated $updatedCount record(s)');

    // Kiểm tra cập nhật
    final updatedUsers = await dbHelper.query(
        'users',
        where: 'username = ?',
        whereArgs: ['test_user']
    );
    if (updatedUsers.isNotEmpty) {
      print('✅ User email updated to: ${updatedUsers.first['email']}');
    }

    // Xóa dữ liệu
    print('5️⃣ Deleting test user...');
    final deletedCount = await dbHelper.delete(
        'users',
        whereClause: 'username = ?',
        whereArgs: ['test_user']
    );
    print('✅ Deleted $deletedCount record(s)');

    // Đóng kết nối
    print('6️⃣ Closing database connection...');
    await dbHelper.close();
    print('✅ Database connection closed');

    print('\n🎉 All tests completed successfully!');
  } catch (e) {
    print('❌ Test failed with error: $e');
    exit(1);
  }
}