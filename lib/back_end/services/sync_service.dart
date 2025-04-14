import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../database/db_connection.dart';
// Đồng bộ dữ liệu vô MySQL
class SyncService {
    Future<Response> syncData(Request request) async {
    final body = await request.readAsString();
    final localData = jsonDecode(body)['users'];

    final conn = await DatabaseConnection.openConnection();
    for (var user in localData) {
      await conn.query(
        'INSERT INTO users (name, password, email) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE email = ?',
        [user['user'], user['password'], user['email']]
      );
    }
    await conn.close();

    return Response.ok(jsonEncode({'message': 'Sync completed'}));
  }
}