// lib/services/auth_service.dart
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
  static Future<bool> register(String name, String email, String password, String passwordConfirmation, String deviceName) async {
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
        return true;
      }

      return false;
    } catch (e) {
      print('Lỗi đăng ký: $e');
      return false;
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