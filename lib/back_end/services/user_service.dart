// lib/services/user_service.dart
import 'dart:io';
import 'package:eng_dictionary/back_end/api_service.dart';

class UserService {
  // Lấy thông tin người dùng
  static Future<Map<String, dynamic>> getUserInfo() async {
    try {
      return await ApiService.get('user');
    } catch (e) {
      print('Lỗi lấy thông tin người dùng: $e');
      return {};
    }
  }

  // Cập nhật ảnh đại diện
  static Future<bool> updateAvatar(File imageFile) async {
    try {
      final response = await ApiService.postWithFiles(
          'user/changeAvatar',
          {},
          {'file': imageFile}
      );

      return response != null && response['avatar'] != null;
    } catch (e) {
      print('Lỗi cập nhật avatar: $e');
      return false;
    }
  }

  // Thay đổi email
  static Future<bool> changeEmail(String newEmail) async {
    try {
      await ApiService.post('user/changeEmail', {
        'email': newEmail
      });
      return true;
    } catch (e) {
      print('Lỗi thay đổi email: $e');
      return false;
    }
  }

  // Thay đổi tên người dùng
  static Future<bool> changeName(String newName) async {
    try {
      await ApiService.post('user/changeName', {
        'name': newName
      });
      return true;
    } catch (e) {
      print('Lỗi thay đổi tên: $e');
      return false;
    }
  }

  // Thay đổi mật khẩu
  static Future<bool> changePassword(String oldPassword, String newPassword, String confirmPassword) async {
    try {
      await ApiService.post('user/changePassword', {
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword
      });
      return true;
    } catch (e) {
      print('Lỗi thay đổi mật khẩu: $e');
      return false;
    }
  }

  // Cập nhật streak
  static Future<bool> updateStreak(int streak) async {
    try {
      await ApiService.post('user/changeStreak', {
        'streak': streak
      });
      return true;
    } catch (e) {
      print('Lỗi cập nhật streak: $e');
      return false;
    }
  }
}