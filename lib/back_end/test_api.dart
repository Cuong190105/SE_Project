// lib/test_api.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:eng_dictionary/back_end/api_service.dart';
import 'package:eng_dictionary/back_end/services/auth_service.dart';
import 'package:eng_dictionary/back_end/services/flashcard_service.dart';
import 'package:eng_dictionary/back_end/services/user_service.dart';
import 'package:eng_dictionary/back_end/services/word_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';


class TestApiScreen extends StatefulWidget {
  const TestApiScreen({Key? key}) : super(key: key);

  @override
  _TestApiScreenState createState() => _TestApiScreenState();
}

class _TestApiScreenState extends State<TestApiScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _result = "Kết quả sẽ hiển thị ở đây";
  bool _isLoading = false;

  // Lấy tên thiết bị cho đăng nhập/đăng ký
  Future<String?> _getDeviceName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.name;
    }
    return 'Unknown device';
  }

  // Kiểm tra đăng nhập
  Future<void> _testLogin() async {
    setState(() {
      _isLoading = true;
      _result = "Đang kiểm tra đăng nhập...";
    });

    try {
      String? deviceName = await _getDeviceName();
      bool success = await AuthService.login(
          _emailController.text,
          _passwordController.text,
          deviceName ?? "Unknown device"
      );

      setState(() {
        _result = success
            ? "Đăng nhập thành công!"
            : "Đăng nhập thất bại!";
      });
    } catch (e) {
      setState(() {
        _result = "Lỗi: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Kiểm tra đăng ký
  Future<void> _testRegister() async {
    setState(() {
      _isLoading = true;
      _result = "Đang kiểm tra đăng ký...";
    });

    try {
      String? deviceName = await _getDeviceName();
      bool success = await AuthService.register(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
          _passwordController.text, // password confirmation
          deviceName ?? "Unknown device"
      );

      setState(() {
        _result = success
            ? "Đăng ký thành công!"
            : "Đăng ký thất bại!";
      });
    } catch (e) {
      setState(() {
        _result = "Lỗi: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Kiểm tra đăng xuất
  Future<void> _testLogout() async {
    setState(() {
      _isLoading = true;
      _result = "Đang kiểm tra đăng xuất...";
    });

    try {
      bool success = await AuthService.logout();
      setState(() {
        _result = success
            ? "Đăng xuất thành công!"
            : "Đăng xuất thất bại!";
      });
    } catch (e) {
      setState(() {
        _result = "Lỗi: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Kiểm tra lấy thông tin người dùng
  Future<void> _testGetUserInfo() async {
    setState(() {
      _isLoading = true;
      _result = "Đang lấy thông tin người dùng...";
    });

    try {
      Map<String, dynamic> userInfo = await UserService.getUserInfo();
      setState(() {
        _result = userInfo.isNotEmpty
            ? "Thông tin người dùng: ${userInfo.toString()}"
            : "Không lấy được thông tin người dùng!";
      });
    } catch (e) {
      setState(() {
        _result = "Lỗi: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Kiểm tra cập nhật avatar
  Future<void> _testUpdateAvatar() async {
    setState(() {
      _isLoading = true;
      _result = "Đang cập nhật avatar...";
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        File imageFile = File(image.path);
        bool success = await UserService.updateAvatar(imageFile);

        setState(() {
          _result = success
              ? "Cập nhật avatar thành công!"
              : "Cập nhật avatar thất bại!";
        });
      } else {
        setState(() {
          _result = "Không có ảnh được chọn!";
        });
      }
    } catch (e) {
      setState(() {
        _result = "Lỗi: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Kiểm tra thay đổi tên người dùng
  Future<void> _testChangeName() async {
    setState(() {
      _isLoading = true;
      _result = "Đang thay đổi tên người dùng...";
    });

    try {
      bool success = await UserService.changeName(_nameController.text);
      setState(() {
        _result = success
            ? "Thay đổi tên thành công!"
            : "Thay đổi tên thất bại!";
      });
    } catch (e) {
      setState(() {
        _result = "Lỗi: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Kiểm tra thay đổi email
  Future<void> _testChangeEmail() async {
    setState(() {
      _isLoading = true;
      _result = "Đang thay đổi email...";
    });

    try {
      bool success = await UserService.changeEmail(_emailController.text);
      setState(() {
        _result = success
            ? "Thay đổi email thành công!"
            : "Thay đổi email thất bại!";
      });
    } catch (e) {
      setState(() {
        _result = "Lỗi: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Kiểm tra thay đổi mật khẩu
  Future<void> _testChangePassword() async {
    setState(() {
      _isLoading = true;
      _result = "Đang thay đổi mật khẩu...";
    });

    try {
      // Giả định rằng _passwordController chứa mật khẩu cũ
      String oldPassword = _passwordController.text;
      String newPassword = "${_passwordController.text}123"; // Thêm "123" để tạo mật khẩu mới

      bool success = await UserService.changePassword(
          oldPassword,
          newPassword,
          newPassword
      );

      setState(() {
        _result = success
            ? "Thay đổi mật khẩu thành công!"
            : "Thay đổi mật khẩu thất bại!";
      });
    } catch (e) {
      setState(() {
        _result = "Lỗi: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Kiểm tra cập nhật streak
  Future<void> _testUpdateStreak() async {
    setState(() {
      _isLoading = true;
      _result = "Đang cập nhật streak...";
    });

    try {
      bool success = await UserService.updateStreak(7); // Cập nhật streak thành 7 ngày
      setState(() {
        _result = success
            ? "Cập nhật streak thành công!"
            : "Cập nhật streak thất bại!";
      });
    } catch (e) {
      setState(() {
        _result = "Lỗi: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Kiểm tra tải xuống từ vựng
  Future<void> _testDownloadWords() async {
    setState(() {
      _isLoading = true;
      _result = "Đang tải xuống từ vựng...";
    });

    try {
      List<Map<String, dynamic>> words = await WordService.downloadWords("0"); // Tải tất cả từ vựng
      setState(() {
        _result = words.isNotEmpty
            ? "Tải xuống ${words.length} từ vựng thành công!"
            : "Không có từ vựng mới!";
      });
    } catch (e) {
      setState(() {
        _result = "Lỗi: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Kiểm tra tải lên từ vựng
  Future<void> _testUploadWords() async {
    setState(() {
      _isLoading = true;
      _result = "Đang tải lên từ vựng...";
    });

    try {
      List<Map<String, dynamic>> testWords = [
        {
          'id': -1, // ID âm cho từ vựng mới
          'vocab': 'test_word',
          'pronunciation': 'test',
          'meaning': 'Từ kiểm tra',
          'example': 'This is a test word.',
          'example_meaning': 'Đây là một từ kiểm tra.',
          'type': 'Danh từ',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'is_deleted': 0
        }
      ];

      Map<String, dynamic> result = await WordService.uploadWords(testWords);
      setState(() {
        _result = "Kết quả tải lên: ${result.toString()}";
      });
    } catch (e) {
      setState(() {
        _result = "Lỗi: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Kiểm tra tải xuống file
  Future<void> _testDownloadFile() async {
    setState(() {
      _isLoading = true;
      _result = "Đang tải xuống file...";
    });

    try {
      // ID từ vựng thực tế từ server
      int wordId = 1; // Giả sử có từ vựng với ID = 1
      String type = "image"; // Có thể là "image", "us_audio", hoặc "uk_audio"

      // Lấy đường dẫn lưu file
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String localPath = "${appDocDir.path}/test_download.$type";

      File? file = await WordService.downloadFile(wordId, type, localPath);
      setState(() {
        _result = file != null
            ? "Tải xuống file thành công! Đường dẫn: ${file.path}"
            : "Tải xuống file thất bại!";
      });
    } catch (e) {
      setState(() {
        _result = "Lỗi: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Kiểm tra tải xuống flashcard
  Future<void> _testDownloadFlashcards() async {
    setState(() {
      _isLoading = true;
      _result = "Đang tải xuống flashcard...";
    });

    try {
      List<Map<String, dynamic>> flashcards = await FlashcardService.downloadFlashcards("0"); // Tải tất cả flashcard
      setState(() {
        _result = flashcards.isNotEmpty
            ? "Tải xuống ${flashcards.length} flashcard thành công!"
            : "Không có flashcard mới!";
      });
    } catch (e) {
      setState(() {
        _result = "Lỗi: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Kiểm tra tải lên flashcard
  Future<void> _testUploadFlashcards() async {
    setState(() {
      _isLoading = true;
      _result = "Đang tải lên flashcard...";
    });

    try {
      List<Map<String, dynamic>> testFlashcards = [
        {
          'id': -1, // ID âm cho flashcard mới
          'front': 'Test Front',
          'back': 'Test Back',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'is_deleted': 0
        }
      ];

      Map<String, dynamic> result = await FlashcardService.uploadFlashcards(testFlashcards);
      setState(() {
        _result = "Kết quả tải lên: ${result.toString()}";
      });
    } catch (e) {
      setState(() {
        _result = "Lỗi: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiểm tra API'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input fields
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Nhập email',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu',
                hintText: 'Nhập mật khẩu',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên',
                hintText: 'Nhập tên',
              ),
            ),
            const SizedBox(height: 20),

            // Auth Service Tests
            Text('Auth Service', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testLogin,
                  child: const Text('Đăng nhập'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testRegister,
                  child: const Text('Đăng ký'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testLogout,
                  child: const Text('Đăng xuất'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // User Service Tests
            Text('User Service', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testGetUserInfo,
                  child: const Text('Lấy thông tin người dùng'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testUpdateAvatar,
                  child: const Text('Cập nhật avatar'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testChangeName,
                  child: const Text('Thay đổi tên'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testChangeEmail,
                  child: const Text('Thay đổi email'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testChangePassword,
                  child: const Text('Thay đổi mật khẩu'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testUpdateStreak,
                  child: const Text('Cập nhật streak'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Word Service Tests
            Text('Word Service', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testDownloadWords,
                  child: const Text('Tải xuống từ vựng'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testUploadWords,
                  child: const Text('Tải lên từ vựng'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testDownloadFile,
                  child: const Text('Tải file'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Flashcard Service Tests
            Text('Flashcard Service', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testDownloadFlashcards,
                  child: const Text('Tải xuống flashcard'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testUploadFlashcards,
                  child: const Text('Tải lên flashcard'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Results area
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kết quả:', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 5),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Text(_result),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
