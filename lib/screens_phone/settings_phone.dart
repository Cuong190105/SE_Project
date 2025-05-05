import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:io';
import '../screens_phone/authentic_phone/login_screen_phone.dart';
import 'package:eng_dictionary/back_end/services/user_service.dart';
import 'package:eng_dictionary/back_end/services/auth_service.dart'; // Giả định có AuthService

class SettingsPhone extends StatefulWidget {
  final int userId;

  const SettingsPhone({super.key, required this.userId});

  @override
  State<SettingsPhone> createState() => _SettingsPhoneState();
}

class _SettingsPhoneState extends State<SettingsPhone> {
  String _name = '';
  String _email = '';
  String _profileImageUrl = 'https://i.pravatar.cc/150';
  bool _isLoading = false;
  String? _errorMessage;

  // Controllers for editing
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String selectedMenu = 'Thông tin tài khoản';
  String _newImagePath = '';
  Map<String, bool> isHoveredMap = {};

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    selectedMenu = 'Menu';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Lấy thông tin người dùng từ backend
  Future<void> _fetchUserInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await UserService.getUserInfo();
    if (result['success']) {
      setState(() {
        _name = result['data']['name'] ?? 'Unknown';
        _email = result['data']['email'] ?? 'Unknown';
        _profileImageUrl = result['data']['avatar'] ?? _profileImageUrl;
        _nameController.text = _name;
        _emailController.text = _email;
      });
    } else {
      setState(() {
        _errorMessage = result['message'];
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  // Chọn ảnh đại diện
  Future<void> _pickImage() async {
    final XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      extensions: <String>['jpg', 'jpeg', 'png'],
    );

    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file != null) {
      setState(() {
        _newImagePath = file.path;
        _isLoading = true;
        _errorMessage = null;
      });

      final result = await UserService.updateAvatar(File(file.path));
      if (result['success']) {
        setState(() {
          _profileImageUrl = result['avatar'];
          _newImagePath = '';
        });
        _showSuccessMessage('Cập nhật ảnh đại diện thành công!');
      } else {
        setState(() {
          _errorMessage = result['message'];
        });
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Xóa ảnh đã chọn (trước khi lưu)
  void _removeImage() {
    setState(() {
      _newImagePath = '';
    });
  }

  // Hiển thị thông báo thành công
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Hiển thị thông báo lỗi
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
            stops: const [0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // User profile header
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade100,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: _newImagePath.isNotEmpty
                          ? FileImage(File(_newImagePath))
                          : NetworkImage(_profileImageUrl) as ImageProvider,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            _email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Loading indicator
              if (_isLoading)
                const Center(child: CircularProgressIndicator()),

              // Error message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),

              // Settings menu and content
              Expanded(
                child: selectedMenu == 'Menu'
                    ? _buildSettingsMenu()
                    : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Back to menu button
                      Align(
                        alignment: Alignment.topLeft,
                        child: TextButton.icon(
                          icon: Icon(Icons.arrow_back,
                              color: Colors.blue.shade700),
                          label: Text(
                            'Quay lại menu',
                            style: TextStyle(color: Colors.blue.shade700),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedMenu = 'Menu';
                              _errorMessage = null;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          child: buildRightContent(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build the settings menu
  Widget _buildSettingsMenu() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSettingsCategory('Tài khoản'),
        _buildSettingsTile(
          icon: Icons.info_outline,
          title: 'Thông tin tài khoản',
          onTap: () => setState(() {
            selectedMenu = 'Thông tin tài khoản';
            _errorMessage = null;
          }),
        ),
        _buildSettingsTile(
          icon: Icons.person_outline,
          title: 'Đổi tên',
          onTap: () => setState(() {
            selectedMenu = 'Đổi tên';
            _errorMessage = null;
          }),
        ),
        _buildSettingsTile(
          icon: Icons.image_outlined,
          title: 'Đổi ảnh đại diện',
          onTap: () => setState(() {
            selectedMenu = 'Đổi ảnh đại diện';
            _errorMessage = null;
          }),
        ),
        _buildSettingsTile(
          icon: Icons.email_outlined,
          title: 'Đổi Email',
          onTap: () => setState(() {
            selectedMenu = 'Đổi Email';
            _errorMessage = null;
          }),
        ),
        _buildSettingsTile(
          icon: Icons.lock_outline,
          title: 'Đổi mật khẩu',
          onTap: () => setState(() {
            selectedMenu = 'Đổi mật khẩu';
            _errorMessage = null;
          }),
        ),
        const SizedBox(height: 16),
        _buildSettingsCategory('Khác'),
        _buildSettingsTile(
          icon: Icons.sync,
          title: 'Đồng bộ',
          onTap: () => setState(() {
            selectedMenu = 'Đồng bộ';
            _errorMessage = null;
          }),
        ),
        _buildSettingsTile(
          icon: Icons.info,
          title: 'Giới thiệu',
          onTap: () => setState(() {
            selectedMenu = 'Giới thiệu';
            _errorMessage = null;
          }),
        ),
        _buildSettingsTile(
          icon: Icons.logout,
          title: 'Đăng xuất',
          textColor: Colors.red,
          onTap: _logout,
        ),
      ],
    );
  }

  Widget _buildSettingsCategory(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade800,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Icon(icon, color: textColor ?? Colors.blue.shade700),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget buildRightContent() {
    switch (selectedMenu) {
      case 'Thông tin tài khoản':
        return profile();
      case 'Đổi tên':
        return changeName();
      case 'Đổi ảnh đại diện':
        return changeProfileImage();
      case 'Đổi Email':
        return changeEmail();
      case 'Đổi mật khẩu':
        return changePassword();
      case 'Đồng bộ':
        return synchronize();
      case 'Giới thiệu':
        return introduction();
      default:
        return Center(
            child: Text('Đang phát triển...', style: TextStyle(fontSize: 20)));
    }
  }

  Widget profile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông tin tài khoản',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: _newImagePath.isNotEmpty
                    ? FileImage(File(_newImagePath))
                    : NetworkImage(_profileImageUrl) as ImageProvider,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(60),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildInfoRow('Họ và tên', _name),
        _buildInfoRow('Email', _email),
      ],
    );
  }

  Widget changeName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đổi tên',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _buildInfoRow('Họ và tên', _name),
        const SizedBox(height: 20),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Họ và tên mới',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập tên';
            }
            return null;
          },
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 10),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
        ],
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateName,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Lưu thay đổi'),
        ),
      ],
    );
  }

  Future<void> _updateName() async {
    if (_nameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập tên';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await UserService.changeName(_nameController.text);
    if (result['success']) {
      setState(() {
        _name = _nameController.text;
      });
      _showSuccessMessage(result['message']);
    } else {
      setState(() {
        _errorMessage = result['message'];
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget changeProfileImage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đổi ảnh đại diện',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Column(
              children: [
                Container(
                  width: 100,
                  height: 130,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(_profileImageUrl),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Ảnh hiện tại',
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const SizedBox(width: 15),
            Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 130,
                      decoration: BoxDecoration(
                        image: _newImagePath.isNotEmpty
                            ? DecorationImage(
                          image: FileImage(File(_newImagePath)),
                          fit: BoxFit.cover,
                        )
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: _newImagePath.isEmpty
                          ? const Center(
                        child: Text(
                          'Chưa chọn ảnh',
                          style: TextStyle(
                              color: Colors.black54, fontSize: 12),
                        ),
                      )
                          : null,
                    ),
                    if (_newImagePath.isNotEmpty)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: _removeImage,
                          child: const CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.black54,
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('Ảnh mới',
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ],
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 10),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Chọn ảnh mới'),
            ),
          ],
        ),
      ],
    );
  }

  Widget changeEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đổi Email',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _buildInfoRow('Email hiện tại', _email),
        const SizedBox(height: 20),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email mới',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Email không hợp lệ';
            }
            return null;
          },
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 10),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
        ],
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateEmail,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Lưu thay đổi'),
        ),
      ],
    );
  }

  Future<void> _updateEmail() async {
    if (_emailController.text.isEmpty ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
            .hasMatch(_emailController.text)) {
      setState(() {
        _errorMessage = 'Vui lòng nhập email hợp lệ';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await UserService.changeEmail(_emailController.text);
    if (result['success']) {
      setState(() {
        _email = _emailController.text;
      });
      _showSuccessMessage(result['message']);
    } else {
      setState(() {
        _errorMessage = result['message'];
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget changePassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đổi mật khẩu',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _oldPasswordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Mật khẩu cũ',
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Mật khẩu mới',
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Xác nhận mật khẩu',
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 10),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
        ],
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _updatePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Lưu thay đổi'),
        ),
      ],
    );
  }

  Future<void> _updatePassword() async {
    if (_oldPasswordController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng điền đầy đủ thông tin';
      });
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Mật khẩu không khớp';
      });
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() {
        _errorMessage = 'Mật khẩu mới phải có ít nhất 6 ký tự';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await UserService.changePassword(
      _oldPasswordController.text,
      _passwordController.text,
      _confirmPasswordController.text,
    );
    if (result['success']) {
      _showSuccessMessage(result['message']);
      _oldPasswordController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    } else {
      setState(() {
        _errorMessage = result['message'];
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Giả định AuthService có hàm logout
      final result = await AuthService.logout();
      if (result['success']) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreenPhone()),
        );
      } else {
        _showErrorMessage(result['message']);
      }
    } catch (e) {
      _showErrorMessage('Lỗi đăng xuất: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget synchronize() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đồng bộ dữ liệu',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text(
          'Đồng bộ streak và dữ liệu từ vựng với máy chủ.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _syncData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Đồng bộ ngay'),
        ),
      ],
    );
  }

  Future<void> _syncData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await UserService.updateStreak(5); // Giả định streak là 5
    if (result['success']) {
      _showSuccessMessage(result['message']);
    } else {
      setState(() {
        _errorMessage = result['message'];
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget introduction() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giới thiệu',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text(
          'Dictionary là ứng dụng học tiếng Anh với các tính năng như tra từ, dịch văn bản, flashcard, và minigame. Chúng tôi giúp bạn học từ vựng hiệu quả và thú vị!',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        const Text(
          'Phiên bản: 1.0.0',
          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 10),
        const Text(
          'Phát triển bởi: Nhóm SE',
          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 10),
        const Text(
          'Liên hệ: support@dictionaryapp.com',
          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Mở trang web hoặc gửi email hỗ trợ
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
          ),
          child: const Text('Tìm hiểu thêm'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}