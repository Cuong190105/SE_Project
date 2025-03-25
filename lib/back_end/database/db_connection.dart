import 'package:mysql1/mysql1.dart';
import 'package:dotenv/dotenv.dart';

class DatabaseConfig {
  static Future<MySqlConnection> connect() async {
    final env = DotEnv()..load();

    try {
      final settings = ConnectionSettings(
        host: env['DB_HOST']!,
        port: int.parse(env['DB_PORT']!),
        user: env['DB_USER']!,
        password: env['DB_PASSWORD']!,
        db: env['DB_NAME']!,  // Chú ý thêm dấu ! để đảm bảo giá trị không null
        timeout: Duration(seconds: 10),
      );

      print('📢 Chi tiết kết nối:');
      print('   Host: ${env['DB_HOST']}');
      print('   Port: ${env['DB_PORT']}');
      print('   User: ${env['DB_USER']}');
      print('   Database: ${env['DB_NAME']}');

      print('🔍 Đang thử kết nối...');
      final connection = await MySqlConnection.connect(settings);

      print('✅ Kết nối thành công!');

      // Kiểm tra cơ sở dữ liệu
      var dbQuery = await connection.query('SELECT DATABASE()');
      var currentDb = env['DB_NAME']!;
      print('📌 Đang kết nối đến database: $currentDb');

      // Kiểm tra danh sách bảng chi tiết
      var tableQuery = await connection.query('''
        SELECT TABLE_NAME 
        FROM INFORMATION_SCHEMA.TABLES 
        WHERE TABLE_SCHEMA = ?
      ''', [env['DB_NAME']]);  // Sử dụng biến môi trường thay vì biến currentDb

      print('📋 Các bảng trong database:');
      final tables = tableQuery.map((row) => row[0].toString()).toList();
      tables.forEach((table) {
        print('   - $table');
      });

      return connection;
    } catch (e, stackTrace) {
      print('❌ Lỗi kết nối chi tiết:');
      print('   Lỗi: $e');
      print('   Chi tiết:');
      print(stackTrace);

      throw Exception('Không thể kết nối đến cơ sở dữ liệu: $e');
    }
  }
}