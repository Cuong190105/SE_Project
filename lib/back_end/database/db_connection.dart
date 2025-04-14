import 'package:mysql1/mysql1.dart';
import 'dart:async';

class DatabaseConnection {
  static final _settings = ConnectionSettings(
    host: 'mysql-128a2e2c-daovanda.k.aivencloud.com', // Địa chỉ MySQL Server
    port: 11446, // Cổng mặc định của MySQL
    user: 'avnadmin', // Tên đăng nhập
    password: 'AVNS_VbUz4_XY1myC4tB0eCD', // Mật khẩu
    db: 'KhoTuVung', // Tên database
    timeout: Duration(seconds: 10), // Thêm timeout để tránh treo kết nối
  );

  /// Mở một kết nối mới đến MySQL
  static Future<MySqlConnection> openConnection() async {
    try {
      return await MySqlConnection.connect(_settings);
    } catch (e) {
      print('❌ Không thể kết nối MySQL: $e');
      throw Exception('Lỗi kết nối MySQL: $e');
    }
  }

  /// Kiểm tra kết nối đến MySQL
  static Future<bool> testConnection() async {
    MySqlConnection? connection;
    try {
      connection = await openConnection();
      await connection.query('SELECT 1'); // Kiểm tra truy vấn đơn giản
      return true;
    } catch (e) {
      print('❌ Lỗi kết nối MySQL: $e');
      return false;
    } finally {
      await connection?.close(); // Luôn đóng kết nối sau khi kiểm tra
    }
  }
}