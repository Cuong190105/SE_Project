import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleDriveService {
  static final _googleSignIn = GoogleSignIn.standard(scopes: [
    drive.DriveApi.driveFileScope,
  ]);

  static Future<drive.DriveApi?> getDriveApi() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final authHeaders = await googleUser.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);

      return drive.DriveApi(authenticateClient);
    } catch (error) {
      print('Error getting Drive API: $error');
      return null;
    }
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}