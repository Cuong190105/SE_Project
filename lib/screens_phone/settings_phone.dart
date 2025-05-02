import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:io';
import '../screens_phone/authentic_phone/login_screen_phone.dart';

class SettingsPhone extends StatefulWidget {
  final int userId;

  const SettingsPhone({super.key, required this.userId});

  @override
  State<SettingsPhone> createState() => _SettingsPhoneState();
}

class _SettingsPhoneState extends State<SettingsPhone> {
  // Sample data for UI display
  String _name = 'Nguyễn Văn B';
  String _email = 'nguyen@example.com';
  String _address = 'Hà Nội';
  String _birthDate = '01/01/1990';
  
  // Controllers for editing
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String selectedMenu = 'Thông tin tài khoản';
  final String _profileImageUrl = 'https://i.pravatar.cc/150';
  String _newImagePath = '';

  @override
  void initState() {
    super.initState();
    // Initialize controllers with sample data
    _nameController.text = _name;
    _emailController.text = _email;
    _addressController.text = _address;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Mock function for image selection
  Future<void> _pickImage() async {
    final XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      extensions: <String>['jpg', 'jpeg', 'png'],
    );

    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file != null) {
      setState(() {
        _newImagePath = file.path;
      });
    }
  }

  // Mock function to remove selected image
  void _removeImage() {
    setState(() {
      _newImagePath = '';
    });
  }

  // Mock function to show success message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
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
                      backgroundImage: NetworkImage(_profileImageUrl),
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
              
              // Settings menu
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSettingsCategory('Tài khoản'),
                    _buildSettingsTile(
                      icon: Icons.info_outline,
                      title: 'Thông tin tài khoản',
                      onTap: () => setState(() => selectedMenu = 'Thông tin tài khoản'),
                    ),
                    _buildSettingsTile(
                      icon: Icons.person_outline,
                      title: 'Đổi tên',
                      onTap: () => setState(() => selectedMenu = 'Đổi tên'),
                    ),
                    _buildSettingsTile(
                      icon: Icons.image_outlined,
                      title: 'Đổi ảnh đại diện',
                      onTap: () => setState(() => selectedMenu = 'Đổi ảnh đại diện'),
                    ),
                    _buildSettingsTile(
                      icon: Icons.email_outlined,
                      title: 'Đổi Email',
                      onTap: () => setState(() => selectedMenu = 'Đổi Email'),
                    ),
                    _buildSettingsTile(
                      icon: Icons.location_on_outlined,
                      title: 'Đổi địa chỉ',
                      onTap: () => setState(() => selectedMenu = 'Đổi địa chỉ'),
                    ),
                    _buildSettingsTile(
                      icon: Icons.lock_outline,
                      title: 'Đổi mật khẩu',
                      onTap: () => setState(() => selectedMenu = 'Đổi mật khẩu'),
                    ),
                    
                    const SizedBox(height: 16),
                    _buildSettingsCategory('Khác'),
                    _buildSettingsTile(
                      icon: Icons.sync,
                      title: 'Đồng bộ',
                      onTap: () => setState(() => selectedMenu = 'Đồng bộ'),
                    ),
                    _buildSettingsTile(
                      icon: Icons.info,
                      title: 'Giới thiệu',
                      onTap: () => setState(() => selectedMenu = 'Giới thiệu'),
                    ),
                    _buildSettingsTile(
                      icon: Icons.logout,
                      title: 'Đăng xuất',
                      textColor: Colors.red,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreenPhone()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Show the selected settings content in a new screen
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.edit, color: Colors.white),
        onPressed: () {
          _showSettingsDetail(context);
        },
      ),
    );
  }

  void _showSettingsDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsDetailScreen(
          title: selectedMenu,
          content: _buildSettingsContent(),
        ),
      ),
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

  Widget _buildSettingsContent() {
    switch (selectedMenu) {
      case 'Thông tin tài khoản':
        return _buildProfile();
      case 'Đổi tên':
        return _buildChangeName();
      case 'Đổi ảnh đại diện':
        return _buildChangeProfileImage();
      case 'Đổi Email':
        return _buildChangeEmail();
      case 'Đổi địa chỉ':
        return _buildChangeAddress();
      case 'Đổi mật khẩu':
        return _buildChangePassword();
      case 'Đồng bộ':
        return _buildSynchronize();
      case 'Giới thiệu':
        return _buildIntroduction();
      default:
        return Center(
          child: Text(
            'Đang phát triển...',
            style: TextStyle(fontSize: 20, color: Colors.blue.shade700),
          ),
        );
    }
  }

  Widget _buildProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông tin tài khoản',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(_profileImageUrl),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(60),
          ),
        ),
        const SizedBox(height: 20),
        _buildInfoRow('Họ và tên', _name),
        _buildInfoRow('Email', _email),
        _buildInfoRow('Ngày sinh', _birthDate),
        _buildInfoRow('Địa chỉ', _address),
      ],
    );
  }

  Widget _buildChangeName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đổi tên',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _buildInfoRow('Họ và tên', _name),
        const SizedBox(height: 20),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Họ và tên',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập họ và tên';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _name = _nameController.text;
            });
            _showSuccessMessage('Cập nhật tên thành công!');
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
          ),
          child: const Text('Lưu thay đổi'),
        ),
      ],
    );
  }

  Widget _buildChangeProfileImage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đổi ảnh đại diện',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Column(
              children: [
                Container(
                  width: 120,
                  height: 160,
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
                const Text('Ảnh hiện tại', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(width: 20),
            Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 160,
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
                                style: TextStyle(color: Colors.black54),
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
                            radius: 12,
                            backgroundColor: Colors.black54,
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('Ảnh mới', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Chọn ảnh mới'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                _showSuccessMessage('Cập nhật ảnh đại diện thành công!');
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Lưu thay đổi'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChangeEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đổi Email',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _buildInfoRow('Email', _email),
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
            return null;
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _email = _emailController.text;
            });
            _showSuccessMessage('Cập nhật email thành công!');
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
          ),
          child: const Text('Lưu thay đổi'),
        ),
      ],
    );
  }

  Widget _buildChangeAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đổi địa chỉ',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _buildInfoRow('Địa chỉ', _address),
        const SizedBox(height: 20),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Địa chỉ mới',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập địa chỉ';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _address = _addressController.text;
            });
            _showSuccessMessage('Cập nhật địa chỉ thành công!');
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
          ),
          child: const Text('Lưu thay đổi'),
        ),
      ],
    );
  }

  Widget _buildChangePassword() {
    return StatefulBuilder(
      builder: (context, setState) {
        String message = '';
        Color messageColor = Colors.black;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Đổi mật khẩu',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Xác nhận mật khẩu',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng xác nhận mật khẩu';
                }
                if (value != _passwordController.text) {
                  return 'Mật khẩu không khớp';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
                  setState(() {
                    message = 'Vui lòng điền đầy đủ thông tin mật khẩu';
                    messageColor = Colors.red;
                  });
                } else if (_passwordController.text != _confirmPasswordController.text) {
                  setState(() {
                    message = 'Mật khẩu không khớp';
                    messageColor = Colors.red;
                  });
                } else {
                  setState(() {
                    message = 'Đổi mật khẩu thành công';
                    messageColor = Colors.blue;
                  });
                  _showSuccessMessage('Đổi mật khẩu thành công!');
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Lưu thay đổi'),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(color: messageColor, fontWeight: FontWeight.bold),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSynchronize() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đồng bộ dữ liệu',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text(
          'Dữ liệu của bạn đã được cập nhật thành công',
          style: TextStyle(fontSize: 16, color: Colors.green),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            _showSuccessMessage('Đã đồng bộ dữ liệu thành công!');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
          ),
          child: const Text('Đồng bộ lại'),
        ),
      ],
    );
  }

  Widget _buildIntroduction() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giới thiệu',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text(
          'Đây là ứng dụng giúp bạn học tiếng Anh hiệu quả với nhiều tính năng hữu ích như từ điển, dịch văn bản, flashcard, và các trò chơi nhỏ để luyện tập.',
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
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Handle learn more action
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

// Settings detail screen
class SettingsDetailScreen extends StatelessWidget {
  final String title;
  final Widget content;

  const SettingsDetailScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
