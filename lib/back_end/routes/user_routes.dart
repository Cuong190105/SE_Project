import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart'; // Import package
import '../services/user_service.dart';
import '../models/user.dart';
import 'dart:convert';

final userService = UserService();

Future<Response> registerUser(Request request) async {
  final payload = jsonDecode(await request.readAsString());

  String email = payload['email'];
  String passwordHash = payload['password']; // Hash mật khẩu trong thực tế
  String? fullName = payload['fullName'];

  int userID = await userService.createUser(
    User(email: email, passwordHash: passwordHash, fullName: fullName),
  );

  return Response.ok(jsonEncode({'userID': userID, 'message': 'User created'}), headers: {'Content-Type': 'application/json'});
}

Handler get userRoutes {
  final router = Router();
  router.post('/register', registerUser);
  return router;
}
