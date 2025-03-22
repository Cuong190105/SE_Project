import 'package:mysql1/mysql1.dart';

class DBConnection {
  static final DBConnection _instance = DBConnection._internal();
  factory DBConnection() => _instance;
  MySqlConnection? _connection;

  DBConnection._internal();

  Future<MySqlConnection> get connection async {
    _connection ??= await createConnection();
    return _connection!;
  }

  Future<MySqlConnection> createConnection() async {
    final settings = ConnectionSettings(
      host: 'localhost',
      port: 3306,
      user: 'root',
      db: 'KhoTuVung',
      password: '00802005',
    );
    return await MySqlConnection.connect(settings);
  }
}
