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
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final name = data['name'];
      final password = data['password'];
      final email = data['email'];

      // Băm mật khẩu
      if (password == null || password.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'Password is required'}));
      }
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();

      // Lưu vào MySQL
      final conn = await DatabaseConnection.openConnection();

      await conn.query(
          'INSERT INTO users (name, email, password) VALUES (?, ?, ?)',
          [name, email, hashedPassword]
      );
      await conn.close();

      // Lưu vào SQLite offline
      await DatabaseHelper.instance.insert('users', {
        'username': name,
        'password_hash': hashedPassword,
        'email': email
      });

      return Response.ok(jsonEncode({
        'message': 'User registered successfully'
      }));
    } catch (e) {
      return Response.internalServerError(
          body: jsonEncode({
            'error': 'Registration failed',
            'details': e.toString()
          })
      );
    }
  }

  // Đăng nhập
  Future<Response> loginUser(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final name = data['username'];
      final password = data['password'];

      final hashedPassword = sha256.convert(utf8.encode(password)).toString();

      // Kiểm tra MySQL
      final conn = await DatabaseConnection.openConnection();
      final results = await conn.query(
          'SELECT * FROM users WHERE name = ? AND password = ?',
          [name, hashedPassword]
      );
      await conn.close();

      if (results.isEmpty) {
        // Thử kiểm tra SQLite nếu MySQL không tìm thấy
        final localResults = await DatabaseHelper.instance.query(
            'users',
            where: 'username = ? AND password_hash = ?',
            whereArgs: [name, hashedPassword]
        );

        if (localResults.isEmpty) {
          return Response.forbidden(jsonEncode({
            'error': 'Invalid credentials'
          }));
        }
      }

      // Tạo JWT
      final jwt = JWT({
        'name': name,
        'exp': DateTime.now().add(Duration(days: 7)).millisecondsSinceEpoch
      });

      final token = jwt.sign(SecretKey('your-secret-key'));

      return Response.ok(jsonEncode({
        'token': token
      }));
    } catch (e) {
      return Response.internalServerError(
          body: jsonEncode({
            'error': 'Login failed',
            'details': e.toString()
          })
      );
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