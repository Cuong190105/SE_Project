// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // URL cơ sở của API
  static const String baseUrl = 'https://edudictionaryserver-production.up.railway.app/api';

  // Header cơ bản cho mọi yêu cầu
  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // GET request
  static Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: await getHeaders(),
      );

      return _processResponse(response);
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // POST request
  static Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: await getHeaders(),
        body: jsonEncode(data),
      );

      return _processResponse(response);
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // POST với file
  static Future<dynamic> postWithFiles(String endpoint, Map<String, String> fields, Map<String, File> files) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/$endpoint'));

      // Thêm header
      final headers = await getHeaders();
      headers.remove('Content-Type'); // Để http tự đặt content-type cho multipart
      request.headers.addAll(headers);

      // Thêm các trường dữ liệu
      request.fields.addAll(fields);

      // Thêm các file
      for (var entry in files.entries) {
        request.files.add(await http.MultipartFile.fromPath(
          entry.key,
          entry.value.path,
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return _processResponse(response);
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Xử lý phản hồi
  static dynamic _processResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        return response.body;
      }
    } else if (response.statusCode == 409) {
      // Xử lý lỗi validation
      final errorResponse = jsonDecode(response.body);
      throw Exception(errorResponse['errors'] ?? 'Lỗi dữ liệu');
    } else if (response.statusCode == 401) {
      // Xử lý lỗi xác thực
      throw Exception('Không có quyền truy cập, vui lòng đăng nhập lại');
    } else {
      throw Exception('Lỗi server (${response.statusCode}): ${response.body}');
    }
  }
}