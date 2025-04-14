import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'dart:convert';
import 'database/db_connection.dart';
import 'services/auth_service.dart';

// Route gốc
Future<Response> rootHandler(Request request) async {
  return Response.ok(
    jsonEncode({
      'message': 'Welcome to the Server',
      'available_routes': ['/test-db', '/health', '/system-info']
    }),
    headers: {'content-type': 'application/json'}
  );
}

// Kiểm tra kết nối MySQL
Future<Response> testDatabaseConnection(Request request) async {
  try {
    final connection = await DatabaseConnection.openConnection();
    await connection.query('SELECT 1'); // Kiểm tra kết nối
    await connection.close(); // Đóng kết nối
    return Response.ok(
      jsonEncode({'status': 'success', 'message': 'Kết nối MySQL thành công'}),
      headers: {'content-type': 'application/json'}
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'status': 'error', 'message': 'Lỗi kết nối MySQL: $e'}),
      headers: {'content-type': 'application/json'}
    );
  }
}

// Kiểm tra trạng thái server
Future<Response> healthCheckHandler(Request request) async {
  return Response.ok(
    jsonEncode({'status': 'ok'}),
    headers: {'content-type': 'application/json'}
  );
}

// Thông tin hệ thống
Future<Response> systemInfoHandler(Request request) async {
  return Response.ok(
    jsonEncode({
      'os': Platform.operatingSystem,
      'version': Platform.version,
      'hostname': Platform.localHostname
    }),
    headers: {'content-type': 'application/json'}
  );
}

void main() async {
  final ip = InternetAddress.anyIPv4;
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  
  // Tạo router
  final router = shelf_router.Router();
  
  // Đăng ký các routes
  router.get('/', rootHandler);
  router.get('/test-db', testDatabaseConnection);
  router.get('/health', healthCheckHandler);
  router.get('/system-info', systemInfoHandler);
  
  // Tạo handler với middleware
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router);

  try {
    final server = await io.serve(handler, ip, port);
    print('Server đang chạy tại http://${server.address.host}:${server.port}');
  } catch (e) {
    print('Lỗi khi khởi động server: $e');
  }
}