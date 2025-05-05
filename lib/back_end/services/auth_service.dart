// lib/back_end/services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eng_dictionary/back_end/api_service.dart';

class AuthService {
  // Đăng nhập
  static Future<bool> login(String email, String password, String deviceName) async {
    try {
      final response = await ApiService.post('login', {
        'email': email,
        'password': password,
        'device_name': deviceName,
      });

      // Lưu token vào storage
      if (response['access_token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', response['access_token']);
        return true;
      }

      return false;
    } catch (e) {
      print('Lỗi đăng nhập: $e');
      return false;
    }
  }

  // Đăng ký
  static Future<Map<String, dynamic>> register(String name, String email, String password, String passwordConfirmation, String deviceName) async {
    try {
      final response = await ApiService.post('register', {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'device_name': deviceName,
      });

      // Lưu token vào storage
      if (response['access_token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', response['access_token']);
        return {
          'success': true,
          'message': response['message'] ?? 'Đăng ký thành công, email xác thực đã được gửi'
        };
      }

      return {'success': false, 'message': 'Đăng ký thất bại'};
    } catch (e) {
      print('Lỗi đăng ký: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Gửi lại email xác thực
  static Future<Map<String, dynamic>> resendVerificationEmail() async {
    try {
      final response = await ApiService.post('verification-notification', {});
      return {
        'success': true,
        'message': 'Email xác thực đã được gửi lại'
      };
    } catch (e) {
      print('Lỗi gửi lại email xác thực: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Quên mật khẩu - Bước 1: Gửi yêu cầu đặt lại mật khẩu
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      await ApiService.post('forgot-password', {
        'email': email,
      });

      return {
        'success': true,
        'message': 'Mã xác minh đã được gửi đến email của bạn'
      };
    } catch (e) {
      print('Lỗi gửi yêu cầu quên mật khẩu: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Quên mật khẩu - Bước 2: Xác minh mã OTP
  static Future<Map<String, dynamic>> verifyResetCode(String email, String code) async {
    try {
      final response = await ApiService.post('verify-reset', {
        'email': email,
        'code': code,
      });

      return {
        'success': true,
        'token': response['token'],
        'message': 'Xác minh mã thành công'
      };
    } catch (e) {
      print('Lỗi xác minh mã OTP: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Quên mật khẩu - Bước 3: Đặt lại mật khẩu
  static Future<Map<String, dynamic>> resetPassword(
      String email, String token, String password, String passwordConfirmation) async {
    try {
      await ApiService.post('reset-password', {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      return {
        'success': true,
        'message': 'Đặt lại mật khẩu thành công'
      };
    } catch (e) {
      print('Lỗi đặt lại mật khẩu: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Đăng xuất
  static Future<bool> logout() async {
    try {
      await ApiService.post('logout', {});

      // Xóa token khỏi storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');

      return true;
    } catch (e) {
      print('Lỗi đăng xuất: $e');
      return false;
    }
  }

  // Kiểm tra đã đăng nhập chưa
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('access_token');
  }

}