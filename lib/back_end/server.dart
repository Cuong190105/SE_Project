import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'database/db_connection.dart';
import 'package:dotenv/dotenv.dart';


class ServerRoutes {
  static Router createRouter() {
    final router = Router();

    router.get('/', (Request request) {
      return Response.ok('✅ Server từ điển đang chạy!');
    });

    router.post('/sync-users', AuthService.syncUsers);


    router.get('/test-db', (Request request) async {
      try {
        final conn = await DatabaseConfig.connect();
        
        final results = await conn.query('SHOW TABLES;');
        print('📢 Số bảng: ${results.length}');
        
        await conn.close();
        
        return Response.ok('✅ Kết nối MySQL thành công! Có ${results.length} bảng.');
      } catch (e) {
        print('❌ Lỗi trong /test-db: $e');
        return Response.internalServerError(body: '❌ Lỗi kết nối MySQL: $e');
      }
    });

    return router;
  }

  static void printRoutes(Router router) {
    print('🔹 Các route đã đăng ký:');
    print('📌 GET /');
    print('📌 GET /test-db');
  }
}

void main() async {
  final router = ServerRoutes.createRouter();
  
  final handler = Pipeline()
    .addMiddleware(logRequests())
    .addHandler(router);

  final server = await shelf_io.serve(
    handler, 
    InternetAddress.anyIPv4, 
    8080
  );

  print('✅ Server chạy tại: http://${server.address.host}:${server.port}');
  ServerRoutes.printRoutes(router);
}