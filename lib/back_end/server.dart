// server.dart
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'dart:convert';
import '../database_SQLite/database_helper.dart';
import 'database/db_connection.dart';
import 'services/auth_service.dart';

// Route gốc
Future<Response> rootHandler(Request request) async {
  return Response.ok(
      jsonEncode({
        'message': 'Welcome to the Server',
        'available_routes': ['/test-db', '/health', '/system-info', '/register', '/login']
      }),
      headers: {'content-type': 'application/json'}
  );
}

// Kiểm tra kết nối MySQL
Future<Response> testDatabaseConnection(Request request) async {
  try {
    final connection = await DatabaseConnection.openConnection();
    final result = await connection.execute('SELECT 1');
    await connection.close();
    return Response.ok(
        jsonEncode({'status': 'success', 'message': 'Kết nối MySQL thành công'}),
        headers: {'content-type': 'application/json'}
    );
  } catch (e) {
    print('❌ Lỗi kiểm tra kết nối: $e');
    return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': 'Lỗi kết nối MySQL: $e'}),
        headers: {'content-type': 'application/json'}
    );
  }
}

// Kiểm tra phiên bản MySQL
Future<Response> mysqlVersionHandler(Request request) async {
  var conn;
  try {
    conn = await DatabaseConnection.openConnection();
    final results = await conn.execute('SELECT VERSION() as version');
    final version = results.rows.first.assoc()['version'] ?? 'Unknown';
    return Response.ok(
        jsonEncode({'status': 'success', 'mysql_version': version}),
        headers: {'content-type': 'application/json'}
    );
  } catch (e) {
    return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'content-type': 'application/json'}
    );
  } finally {
    await conn?.close();
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

  // Khởi tạo cơ sở dữ liệu
  print('Khởi tạo cơ sở dữ liệu...');
  await DatabaseConnection.ensureTablesExist();
  // Xóa và tạo lại cơ sở dữ liệu SQLite
  print('Xóa và tạo lại cơ sở dữ liệu SQLite...');
  await DatabaseHelper.instance.deleteDatabase();
  await DatabaseHelper.instance.database; // Kích hoạt việc tạo lại
  // Tạo router
  final router = shelf_router.Router();

  final authService = AuthService();

  // Đăng ký các routes
  router.get('/', rootHandler);
  router.get('/test-db', testDatabaseConnection);
  router.get('/health', healthCheckHandler);
  router.get('/system-info', systemInfoHandler);
  router.get('/mysql-version', mysqlVersionHandler);
  router.post('/register', authService.registerUser);
  router.post('/login', authService.loginUser);

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