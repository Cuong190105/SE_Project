import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;
import 'package:eng_dictionary/data/models/database_helper.dart';
import 'api_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AuthService {
  static const String baseUrl = 'https://edudictionaryserver-production.up.railway.app/api';

  static Future<Map<String, dynamic>> login(String email, String password, String deviceName) async {
    try {
      final response = await ApiService.post('login', {
        'email': email,
        'password': password,
        'device_name': deviceName,
      });

      if (response is Map<String, dynamic> && response['access_token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', response['access_token']);
        await prefs.setString('user_email', email);
        await prefs.setString('user_name', response['name'] ?? '');
        print('djfnhduhfud$response');
        return {
          'success': true,
          'message': 'Đăng nhập thành công',
        };
      }

      return {
        'success': false,
        'message': (response is Map<String, dynamic> && response['message'] != null)
            ? response['message']
            : 'Email hoặc mật khẩu không đúng',
      };
    } catch (e) {
      debugPrint('Lỗi đăng nhập: $e');
      String message = 'Đăng nhập thất bại. Vui lòng thử lại.';
      if (e.toString().contains('SocketException')) {
        message = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
      }
      return {
        'success': false,
        'message': message,
      };
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password, String passwordConfirmation, String deviceName) async {
    try {
      final response = await ApiService.post('register', {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'device_name': deviceName,
      });

      if (response is Map<String, dynamic> && response['access_token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', response['access_token']);
        await prefs.setString('user_email', email);
        await prefs.setString('user_name', name);

        return {
          'success': true,
          'message': response['message'] ?? 'Đăng ký thành công, email xác thực đã được gửi',
        };
      }

      return {
        'success': false,
        'message': (response is Map<String, dynamic> && response['message'] != null)
            ? response['message']
            : 'Đăng ký thất bại',
      };
    } catch (e) {
      debugPrint('Lỗi đăng ký: $e');
      String message = 'Đăng ký thất bại. Vui lòng thử lại.';
      if (e.toString().contains('SocketException')) {
        message = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
      }
      return {
        'success': false,
        'message': message,
      };
    }
  }

  static Future<Map<String, dynamic>> resendVerificationEmail(String email) async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return {
          'success': false,
          'message': 'Không có kết nối mạng. Vui lòng kiểm tra kết nối của bạn.',
        };
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) {
        return {
          'success': false,
          'message': 'Không tìm thấy token xác thực. Vui lòng đăng nhập lại.',
        };
      }

      final response = await ApiService.post('email/resend', {'email': email});

      if (response is Map<String, dynamic>) {
        return {
          'success': response['success'] ?? true,
          'message': response['message'] ?? 'Email xác thực đã được gửi lại',
        };
      }

      return {
        'success': false,
        'message': 'Phản hồi không hợp lệ từ server',
      };
    } catch (e) {
      debugPrint('Lỗi gửi lại email xác thực: $e');
      String message = 'Gửi lại email xác thực thất bại. Vui lòng thử lại.';
      if (e.toString().contains('SocketException')) {
        message = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
      }
      return {
        'success': false,
        'message': message,
      };
    }
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return {
          'success': false,
          'message': 'Không có kết nối mạng. Vui lòng kiểm tra kết nối của bạn.',
        };
      }

      // Gọi API trực tiếp để bỏ header Authorization
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      debugPrint('Phản hồi từ forgot-password (status: ${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('reset_email', email);
        return {
          'success': true,
          'message': (body is Map<String, dynamic> && body['message'] != null)
              ? body['message']
              : 'Mã OTP đã được gửi đến email của bạn',
        };
      } else if (response.statusCode == 409) {
        final body = jsonDecode(response.body);
        return {
          'success': false,
          'message': (body is Map<String, dynamic> && body['message'] != null)
              ? body['message']
              : 'Email không tồn tại trong hệ thống',
        };
      }

      final body = jsonDecode(response.body);
      return {
        'success': false,
        'message': (body is Map<String, dynamic> && body['message'] != null)
            ? body['message']
            : 'Yêu cầu thất bại. Vui lòng thử lại.',
      };
    } catch (e) {
      debugPrint('Lỗi gửi yêu cầu quên mật khẩu: $e');
      String message = 'Gửi yêu cầu quên mật khẩu thất bại. Vui lòng thử lại.';
      if (e.toString().contains('SocketException')) {
        message = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
      } else if (e.toString().contains('422')) {
        message = 'Dữ liệu không hợp lệ. Vui lòng kiểm tra email.';
      }
      return {
        'success': false,
        'message': message,
      };
    }
  }

  static Future<Map<String, dynamic>> verifyResetCode(String email, String code) async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return {
          'success': false,
          'message': 'Không có kết nối mạng. Vui lòng kiểm tra kết nối của bạn.',
        };
      }

      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('reset_email');
      if (savedEmail == null || savedEmail != email) {
        return {
          'success': false,
          'message': 'Email không khớp với yêu cầu trước đó',
        };
      }

      // Gọi API trực tiếp để bỏ header Authorization
      final response = await http.post(
        Uri.parse('$baseUrl/verify-reset'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': savedEmail,
          'code': code,
        }),
      );

      debugPrint('Phản hồi từ verify-reset: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic> && body['token'] != null) {
          return {
            'success': true,
            'message': 'Mã OTP hợp lệ',
            'token': body['token'],
          };
        }
      }

      final body = jsonDecode(response.body);
      return {
        'success': false,
        'message': (body is Map<String, dynamic> && body['message'] != null)
            ? body['message']
            : 'Mã OTP không hợp lệ hoặc đã hết hạn',
      };
    } catch (e) {
      debugPrint('Lỗi xác thực mã OTP: $e');
      String message = 'Xác thực mã OTP thất bại. Vui lòng thử lại.';
      if (e.toString().contains('SocketException')) {
        message = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
      } else if (e.toString().contains('422')) {
        message = 'Mã OTP không hợp lệ. Vui lòng kiểm tra lại.';
      }
      return {
        'success': false,
        'message': message,
      };
    }
  }

  static Future<Map<String, dynamic>> resetPassword(String email, String token, String password, String passwordConfirmation) async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return {
          'success': false,
          'message': 'Không có kết nối mạng. Vui lòng kiểm tra kết nối của bạn.',
        };
      }

      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('reset_email');
      if (savedEmail == null || savedEmail != email) {
        return {
          'success': false,
          'message': 'Email không khớp với yêu cầu trước đó',
        };
      }

      // Gọi API trực tiếp để bỏ header Authorization
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': savedEmail,
          'token': token,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      debugPrint('Phản hồi từ reset-password: ${response.body}');

      if (response.statusCode == 200) {
        await prefs.remove('reset_email');
        final body = jsonDecode(response.body);
        return {
          'success': true,
          'message': (body is Map<String, dynamic> && body['message'] != null)
              ? body['message']
              : 'Mật khẩu đã được đặt lại thành công',
        };
      }

      final body = jsonDecode(response.body);
      return {
        'success': false,
        'message': (body is Map<String, dynamic> && body['message'] != null)
            ? body['message']
            : 'Đặt lại mật khẩu thất bại',
      };
    } catch (e) {
      debugPrint('Lỗi đặt lại mật khẩu: $e');
      String message = 'Đặt lại mật khẩu thất bại. Vui lòng thử lại.';
      if (e.toString().contains('SocketException')) {
        message = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
      } else if (e.toString().contains('422')) {
        message = 'Dữ liệu không hợp lệ. Vui lòng kiểm tra mật khẩu.';
      }
      return {
        'success': false,
        'message': message,
      };
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return {
          'success': false,
          'message': 'Không có kết nối mạng. Vui lòng kiểm tra kết nối của bạn.',
        };
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) {
        return {
          'success': false,
          'message': 'Không tìm thấy token xác thực. Vui lòng đăng nhập lại.',
        };
      }

      final response = await ApiService.post('logout', {});

      if (response is Map<String, dynamic> && (response['success'] ?? true)) {
        await prefs.remove('access_token');
        await prefs.remove('user_email');
        await prefs.remove('reset_email');

        try {
          final db = await DatabaseHelper.instance.database;
          final tables = db.select("SELECT name FROM sqlite_master WHERE type='table' AND name IN ('flashcard_sets', 'flashcards')");
          for (var table in tables) {
            final tableName = table['name'] as String;
            debugPrint('Dữ liệu từ bảng $tableName đã được xóa.');
          }
          if (tables.isEmpty) {
            debugPrint('Không tìm thấy bảng flashcard_sets hoặc flashcards.');
          }
        } catch (e) {
          debugPrint('Lỗi khi xóa dữ liệu cơ sở dữ liệu: $e');
        }

        return {
          'success': true,
          'message': response['message'] ?? 'Đăng xuất thành công',
        };
      }

      return {
        'success': false,
        'message': (response is Map<String, dynamic> && response['message'] != null)
            ? response['message']
            : 'Đăng xuất thất bại. Vui lòng thử lại.',
      };
    } catch (e) {
      debugPrint('Lỗi đăng xuất: $e');
      String message = 'Đăng xuất thất bại. Vui lòng thử lại.';
      if (e.toString().contains('SocketException')) {
        message = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
      }
      return {
        'success': false,
        'message': message,
      };
    }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') != null;
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name') ?? 'người dùng';;
  }
}