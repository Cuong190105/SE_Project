// lib/services/word_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:eng_dictionary/back_end/api_service.dart';
import 'package:http/http.dart' as http;

class WordService {
  // Tải lên từ vựng
  static Future<Map<String, dynamic>> uploadWords(List<Map<String, dynamic>> words,
      {Map<int, File>? images, Map<int, File>? usAudios, Map<int, File>? ukAudios}) async {
    try {
      final Map<String, String> fields = {
        'payload': jsonEncode({'change': words})
      };

      final Map<String, File> files = {};

      // Thêm các file hình ảnh nếu có
      if (images != null) {
        images.forEach((wordId, file) {
          files['media[images][$wordId]'] = file;
        });
      }

      // Thêm các file âm thanh US nếu có
      if (usAudios != null) {
        usAudios.forEach((wordId, file) {
          files['media[usAudio][$wordId]'] = file;
        });
      }

      // Thêm các file âm thanh UK nếu có
      if (ukAudios != null) {
        ukAudios.forEach((wordId, file) {
          files['media[ukAudio][$wordId]'] = file;
        });
      }

      return await ApiService.postWithFiles('sync/uploadWords', fields, files);
    } catch (e) {
      print('Lỗi tải lên từ vựng: $e');
      return {'errors': []};
    }
  }

  // Tải xuống từ vựng mới
  static Future<List<Map<String, dynamic>>> downloadWords(String timestamp) async {
    try {
      final response = await ApiService.get('sync/downloadWords?timestamp=$timestamp');
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      print('Lỗi tải xuống từ vựng: $e');
      return [];
    }
  }

  // Tải xuống file cho từ vựng
  static Future<File?> downloadFile(int wordId, String type, String localPath) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/sync/files?word_id=$wordId&type=$type'),
        headers: await ApiService.getHeaders(),
      );

      if (response.statusCode == 200) {
        final file = File(localPath);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
      return null;
    } catch (e) {
      print('Lỗi tải xuống file: $e');
      return null;
    }
  }
}