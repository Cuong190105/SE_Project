import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'routes/user_routes.dart';

void main() async {
  var handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(userRoutes);

  var server = await io.serve(handler, 'localhost', 8080);
  print('Server running on localhost:${server.port}');
}
