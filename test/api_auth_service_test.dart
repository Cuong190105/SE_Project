/*import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eng_dictionary/core/services/api_service.dart';
import 'package:eng_dictionary/core/services/auth_service.dart';
import 'api_auth_service_test.mocks.dart';
import 'package:eng_dictionary/core/services/api_service.dart';
import 'package:eng_dictionary/core/services/auth_service.dart';
// Tạo mock bằng mockito
@GenerateMocks([http.Client, SharedPreferences])
void main() {
  late MockClient mockHttpClient;
  late MockSharedPreferences mockSharedPreferences;
  late AuthService authService;

  setUp(() {
    mockHttpClient = MockClient();
    mockSharedPreferences = MockSharedPreferences();
    authService = AuthService();
  });

  // Helper để thiết lập mock cho SharedPreferences
  void setUpSharedPreferences({String? token, String? email}) {
    when(mockSharedPreferences.getString('access_token')).thenReturn(token);
    when(mockSharedPreferences.getString('user_email')).thenReturn(email);
    when(mockSharedPreferences.setString(any, any)).thenAnswer((_) async => true);
    when(mockSharedPreferences.remove(any)).thenAnswer((_) async => true);
  }

  // Group test cho ApiService
  group('ApiService', () {
    const baseUrl = 'https://edudictionaryserver-production.up.railway.app/api';

    test('get returns decoded JSON on success', () async {
      // Arrange
      final endpoint = 'test-endpoint';
      final responseBody = {'data': 'test'};
      when(mockHttpClient.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(responseBody), 200));

      // Act
      final result = await ApiService.get(endpoint);

      // Assert
      expect(result, equals(responseBody));
      verify(mockHttpClient.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: anyNamed('headers'),
      )).called(1);
    });

    test('get throws exception on connection error', () async {
      // Arrange
      final endpoint = 'test-endpoint';
      when(mockHttpClient.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: anyNamed('headers'),
      )).thenThrow(const SocketException('Connection failed'));

      // Act & Assert
      expect(() => ApiService.get(endpoint), throwsException);
    });

    test('post returns decoded JSON on success', () async {
      // Arrange
      final endpoint = 'test-endpoint';
      final data = {'key': 'value'};
      final responseBody = {'data': 'test'};
      when(mockHttpClient.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: anyNamed('headers'),
        body: jsonEncode(data),
      )).thenAnswer((_) async => http.Response(jsonEncode(responseBody), 200));

      // Act
      final result = await ApiService.post(endpoint, data);

      // Assert
      expect(result, equals(responseBody));
      verify(mockHttpClient.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: anyNamed('headers'),
        body: jsonEncode(data),
      )).called(1);
    });

    test('post throws exception on 401 error', () async {
      // Arrange
      final endpoint = 'test-endpoint';
      final data = {'key': 'value'};
      when(mockHttpClient.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: anyNamed('headers'),
        body: jsonEncode(data),
      )).thenAnswer((_) async => http.Response('Unauthorized', 401));

      // Act & Assert
      expect(() => ApiService.post(endpoint, data), throwsException);
    });

    test('postWithFiles uploads files and returns response', () async {
      // Arrange
      final endpoint = 'test-endpoint';
      final fields = {'field': 'value'};
      final files = {'file': File('test.txt')};
      final responseBody = {'data': 'uploaded'};
      final mockStreamedResponse = http.StreamedResponse(
        Stream.value(utf8.encode(jsonEncode(responseBody))),
        200,
      );

      when(mockHttpClient.send(any)).thenAnswer((_) async => mockStreamedResponse);

      // Act
      final result = await ApiService.postWithFiles(endpoint, fields, files);

      // Assert
      expect(result, equals(responseBody));
    });

    test('processResponse throws exception on 409 error', () async {
      // Arrange
      final response = http.Response(
        jsonEncode({'errors': 'Validation failed'}),
        409,
      );

      // Act & Assert
      expect(() => ApiService._processResponse(response), throwsException);
    });
  });

  // Group test cho AuthService
  group('AuthService', () {
    const baseUrl = 'https://edudictionaryserver-production.up.railway.app/api';

    test('login succeeds and saves token', () async {
      // Arrange
      setUpSharedPreferences();
      final responseBody = {
        'access_token': 'test_token',
        'message': 'Login successful',
      };
      when(mockHttpClient.post(
        Uri.parse('$baseUrl/login'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode(responseBody), 200));

      // Act
      final result = await authService.login('test@example.com', 'password', 'device');

      // Assert
      expect(result['success'], isTrue);
      expect(result['message'], equals('Đăng nhập thành công'));
      verify(mockSharedPreferences.setString('access_token', 'test_token')).called(1);
      verify(mockSharedPreferences.setString('user_email', 'test@example.com')).called(1);
    });

    test('login fails with incorrect credentials', () async {
      // Arrange
      setUpSharedPreferences();
      final responseBody = {'message': 'Invalid credentials'};
      when(mockHttpClient.post(
        Uri.parse('$baseUrl/login'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode(responseBody), 401));

      // Act
      final result = await authService.login('test@example.com', 'wrong', 'device');

      // Assert
      expect(result['success'], isFalse);
      expect(result['message'], equals('Email hoặc mật khẩu không đúng'));
    });

    test('register succeeds and saves token', () async {
      // Arrange
      setUpSharedPreferences();
      final responseBody = {
        'access_token': 'test_token',
        'message': 'Registration successful',
      };
      when(mockHttpClient.post(
        Uri.parse('$baseUrl/register'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode(responseBody), 200));

      // Act
      final result = await authService.register(
        'Test User',
        'test@example.com',
        'password',
        'password',
        'device',
      );

      // Assert
      expect(result['success'], isTrue);
      expect(result['message'], equals('Đăng ký thành công, email xác thực đã được gửi'));
      verify(mockSharedPreferences.setString('access_token', 'test_token')).called(1);
      verify(mockSharedPreferences.setString('user_email', 'test@example.com')).called(1);
    });

    test('logout clears tokens and returns success', () async {
      // Arrange
      setUpSharedPreferences(token: 'test_token', email: 'test@example.com');
      final responseBody = {'success': true, 'message': 'Logout successful'};
      when(mockHttpClient.post(
        Uri.parse('$baseUrl/logout'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode(responseBody), 200));

      // Act
      final result = await authService.logout();

      // Assert
      expect(result['success'], isTrue);
      expect(result['message'], equals('Đăng xuất thành công'));
      verify(mockSharedPreferences.remove('access_token')).called(1);
      verify(mockSharedPreferences.remove('user_email')).called(1);
      verify(mockSharedPreferences.remove('reset_email')).called(1);
    });

    test('isLoggedIn returns true when token exists', () async {
      // Arrange
      setUpSharedPreferences(token: 'test_token');

      // Act
      final isLoggedIn = await authService.isLoggedIn();

      // Assert
      expect(isLoggedIn, isTrue);
    });

    test('isLoggedIn returns false when token is null', () async {
      // Arrange
      setUpSharedPreferences();

      // Act
      final isLoggedIn = await authService.isLoggedIn();

      // Assert
      expect(isLoggedIn, isFalse);
    });

    test('getUserEmail returns email when it exists', () async {
      // Arrange
      setUpSharedPreferences(email: 'test@example.com');

      // Act
      final email = await authService.getUserEmail();

      // Assert
      expect(email, equals('test@example.com'));
    });

    test('getUserEmail returns null when email is not set', () async {
      // Arrange
      setUpSharedPreferences();

      // Act
      final email = await authService.getUserEmail();

      // Assert
      expect(email, isNull);
    });
  });
}*/