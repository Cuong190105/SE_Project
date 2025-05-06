// db_connection.dart
import 'package:mysql_client/mysql_client.dart';

class DatabaseConnection {
  static Future<MySQLConnection> openConnection() async {
    try {
      final conn = await MySQLConnection.createConnection(
        host: '127.0.0.1',
        port: 3306,
        userName: 'root',
        password: '00802005',
        databaseName: 'KhoTuVung',
        secure: true,
      );
      await conn.connect();
      print('✅ Kết nối MySQL thành công');
      return conn;
    } catch (e) {
      print('❌ Không thể kết nối MySQL: $e');
      throw Exception('Lỗi kết nối MySQL: $e');
    }
  }

  /// Kiểm tra kết nối đến MySQL
  static Future<bool> testConnection() async {
    MySQLConnection? connection;
    try {
      connection = await openConnection();
      final result = await connection.execute('SELECT 1');
      return true;
    } catch (e) {
      print('❌ Lỗi kết nối MySQL: $e');
      return false;
    } finally {
      await connection?.close(); // Luôn đóng kết nối sau khi kiểm tra
    }
  }

  /// Đảm bảo các bảng cần thiết tồn tại
  static Future<void> ensureTablesExist() async {
    MySQLConnection? conn;
    try {
      conn = await openConnection();
      // Tạo bảng users nếu chưa tồn tại
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id INT AUTO_INCREMENT PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          email VARCHAR(255) NOT NULL,
          password VARCHAR(255) NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      ''');
      print('✅ Đã kiểm tra bảng users');
    } catch (e) {
      print('❌ Lỗi khi tạo bảng: $e');
    } finally {
      await conn?.close();
    }
  }
}