// lib/services/user_service.dart
import 'dart:io';
import 'package:eng_dictionary/back_end/api_service.dart';

class UserService {
  // Lấy thông tin người dùng
  static Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final response = await ApiService.get('user');
      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi lấy thông tin người dùng: $e',
      };
    }
  }

  // Cập nhật ảnh đại diện
  static Future<Map<String, dynamic>> updateAvatar(File imageFile) async {
    try {
      final response = await ApiService.postWithFiles(
        'user/changeAvatar',
        {},
        {'file': imageFile},
      );
      if (response != null && response['avatar'] != null) {
        return {
          'success': true,
          'avatar': response['avatar'],
        };
      } else {
        return {
          'success': false,
          'message': 'Không thể cập nhật ảnh đại diện',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi cập nhật ảnh đại diện: $e',
      };
    }
  }

  // Thay đổi email
  static Future<Map<String, dynamic>> changeEmail(String newEmail) async {
    try {
      await ApiService.post('user/changeEmail', {
        'email': newEmail,
      });
      return {
        'success': true,
        'message': 'Thay đổi email thành công',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi thay đổi email: $e',
      };
    }
  }

  // Thay đổi tên người dùng
  static Future<Map<String, dynamic>> changeName(String newName) async {
    try {
      await ApiService.post('user/changeName', {
        'name': newName,
      });
      return {
        'success': true,
        'message': 'Thay đổi tên thành công',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi thay đổi tên: $e',
      };
    }
  }

  // Thay đổi mật khẩu
  static Future<Map<String, dynamic>> changePassword(
      String oldPassword, String newPassword, String confirmPassword) async {
    try {
      await ApiService.post('user/changePassword', {
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      });
      return {
        'success': true,
        'message': 'Thay đổi mật khẩu thành công',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi thay đổi mật khẩu: $e',
      };
    }
  }

  // Cập nhật streak
  static Future<Map<String, dynamic>> updateStreak(int streak) async {
    try {
      await ApiService.post('user/changeStreak', {
        'streak': streak,
      });
      return {
        'success': true,
        'message': 'Cập nhật streak thành công',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi cập nhật streak: $e',
      };
    }
  }
}