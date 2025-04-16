// auth_service.dart
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../../database_SQLite/database_helper.dart';
import '../database/db_connection.dart';

class AuthService {
  // Đăng ký
  Future<Response> registerUser(Request request) async {
    print('1. Bắt đầu xử lý đăng ký');
    var conn;
    try {
      final body = await request.readAsString();
      print('2. Đã đọc body: $body');

      final data = jsonDecode(body);
      print('3. Đã parse JSON: $data');

      final name = data['name'];
      final email = data['email'];
      final password = data['password'];
      print('4. Đã lấy dữ liệu: name=$name, email=$email, password=***');

      // Băm mật khẩu
      if (password == null || password.isEmpty) {
        return Response.badRequest(
            body: jsonEncode({'error': 'Password is required'}),
            headers: {'content-type': 'application/json'}
        );
      }
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();
      print('5. Đã hash password: $hashedPassword');

      // Lưu vào MySQL
      print('6. Chuẩn bị kết nối MySQL');
      conn = await DatabaseConnection.openConnection();
      print('7. Đã kết nối MySQL thành công');

      print('8. Chuẩn bị thực hiện truy vấn');

      final result = await conn.execute(
          'INSERT INTO users (name, email, password) VALUES (:param1, :param2, :param3)',
          {'param1': name, 'param2': email, 'param3': hashedPassword}
      );
      print('9. Đã thực hiện truy vấn MySQL thành công');

      // Lưu vào SQLite offline
      await DatabaseHelper.instance.insert('users', {
        'username': name,
        'email': email,
        'password': hashedPassword  // Đã sửa khóa đúng với tên cột trong bảng
      });
      print('10. Đã lưu vào SQLite thành công');

      return Response.ok(
          jsonEncode({'message': 'User registered successfully'}),
          headers: {'content-type': 'application/json'}
      );
    } catch (e, stackTrace) {
      print('❌ Lỗi đăng ký: $e');
      print('❌ Stack trace: $stackTrace');
      return Response.internalServerError(
          body: jsonEncode({
            'error': 'Registration failed',
            'details': e.toString()
          }),
          headers: {'content-type': 'application/json'}
      );
    } finally {
      await conn?.close(); // Đảm bảo luôn đóng kết nối
      print('11. Đã đóng kết nối MySQL');
    }
  }

  // Đăng nhập
  Future<Response> loginUser(Request request) async {
    var conn;
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final name = data['username'];
      final password = data['password'];

      final hashedPassword = sha256.convert(utf8.encode(password)).toString();

      // Kiểm tra MySQL
      conn = await DatabaseConnection.openConnection();
      final results = await conn.execute(
          'SELECT * FROM users WHERE name = :name AND password = :password',
          {'name': name, 'password': hashedPassword}
      );

      // Kiểm tra kết quả
      if (results.rows.isEmpty) {
        // Thử kiểm tra SQLite nếu MySQL không tìm thấy
        final localResults = await DatabaseHelper.instance.query(
            'users',
            where: 'username = ? AND password_hash = ?',
            whereArgs: [name, hashedPassword]
        );

        if (localResults.isEmpty) {
          return Response.forbidden(
              jsonEncode({'error': 'Invalid credentials'}),
              headers: {'content-type': 'application/json'}
          );
        }
      }

      // Tạo JWT
      final jwt = JWT({
        'name': name,
        'exp': DateTime.now().add(Duration(days: 7)).millisecondsSinceEpoch
      });

      final token = jwt.sign(SecretKey('your-secret-key'));

      return Response.ok(
          jsonEncode({'token': token}),
          headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response.internalServerError(
          body: jsonEncode({
            'error': 'Login failed',
            'details': e.toString()
          }),
          headers: {'content-type': 'application/json'}
      );
    } finally {
      await conn?.close();
    }
  }

  // Đồng bộ dữ liệu
  Future<void> syncData() async {
    try {
      // Lấy dữ liệu từ SQLite
      final localUsers = await DatabaseHelper.instance.query('users');

      // Nếu có dữ liệu để đồng bộ
      if (localUsers.isNotEmpty) {
        final response = await http.post(
          Uri.parse('https://your-api.com/sync'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'users': localUsers}),
        );

        if (response.statusCode == 200) {
          print('Sync successful');
          // Có thể thêm logic xóa dữ liệu local sau khi đồng bộ thành công
        } else {
          print('Sync failed: ${response.body}');
        }
      }
    } catch (e) {
      print('Sync error: $e');
    }
  }
}