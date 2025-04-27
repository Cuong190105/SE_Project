import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_desktop.dart';
import 'dart:convert';
import 'package:eng_dictionary/screens_desktop/authentic_desktop/register_screen.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'user_profile_service.dart';
import 'package:mysql1/mysql1.dart';

class Settings extends StatefulWidget {
  final int userId;

  Settings({required this.userId});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  // sửa lại sau khi tích hợp backend nhé bao gồm các file class

  // Khai báo các controller
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  final _userProfileService = UserProfileService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String selectedMenu = 'Thông tin tài khoản';
  Map<String, bool> isHoveredMap = {};

  final String _oldImageUrl = 'https://i.pravatar.cc/150';
  String _newImagePath = '';

  Future<void> updateUserProfile() async {
    final success = await _userProfileService.updateUser(
      userId: widget.userId,
      fullName: _nameController.text,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
      address: _addressController.text,
      password: _passwordController.text,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thông tin thành công!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thông tin thất bại!')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    int streakCount = 5; // Đợi dữ liệu từ database
    bool _isHovering = false;
    bool isHoveringIcon = false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
        leadingWidth: screenWidth,
        leading: Stack(
          children: [
            Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'DICTIONARY',
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  StatefulBuilder(
                    builder: (context, setState) {

                      return MouseRegion(
                        onEnter: (_) => setState(() => isHoveringIcon = true),
                        onExit: (_) => setState(() => isHoveringIcon = false),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const HomeScreenDesktop()),
                            );
                          },
                          customBorder: const CircleBorder(), // Để hiệu ứng nhấn bo tròn đúng hình
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: isHoveringIcon ? Colors.grey.shade300 : Colors.white, // Hover đổi màu
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.shade100,
                                  blurRadius: 2,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.book,
                              size: 20,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Text(
                "$streakCount",
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
            ],
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle),
              child: Icon(Icons.person, color: Colors.blue.shade700, size: 20),
            ),
            onPressed: () {},
          ),
        ],
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
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return MouseRegion(
                          onEnter: (_) => setState(() => _isHovering = true),
                          onExit: (_) => setState(() => _isHovering = false),
                          child: Material(
                            color: _isHovering ? Colors.grey.shade300 : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              borderRadius: BorderRadius.circular(30),
                              splashColor: Colors.blue.withOpacity(0.2),
                              highlightColor: Colors.blue.withOpacity(0.1),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    buttonBack(context),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Cài đặt',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    leftSideWidget(),
                    rightSideWidget(),
                  ]
                ),

                const SizedBox(height: 24),
              ],
            ),
        ),
      ),
    );
  }

  // Nút quay lại
  Widget buttonBack(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft, // Canh về góc trái trên
      child: IconButton(
        icon: Icon(Icons.arrow_back, size: 30, color: Colors.blue.shade700),
        onPressed: () {
          Navigator.pop(context); // Quay lại màn hình trước đó
        },

        hoverColor: Colors.grey.shade300.withOpacity(0),
      ),
    );
  }
  //
  Widget buildRightContent() {
    switch (selectedMenu) {
      case 'Thông tin tài khoản':
        return profile();  // Widget thông tin tài khoản
      case 'Đổi tên':
        return changeName();  // Widget đổi tên
      case 'Đổi ảnh đại diện':
        return changeProfileImage();  // Widget đổi ảnh đại diện
      case 'Đổi Gmail':
        return changeEmail();  // Widget đổi Gmail
      case 'Đổi Số điện thoại':
        return changePhoneNumber();  // Widget đổi Số điện thoại
      case 'Đổi địa chỉ':
        return changeAddress();  // Widget đổi địa chỉ
      case 'Đổi mật khẩu':
        return changePassword();  // Widget đổi mật khẩu
      case 'Giới thiệu':
        return introduction();  // Widget giới thiệu
      default:
        return Center(child: Text('Đang phát triển...', style: TextStyle(fontSize: 20)));
    }
  }
  //tạo nút Menu bên trái
  Widget buildMenuButtonWithIcon(IconData icon, String title, {bool isLogout = false}) {
    bool isSelected = selectedMenu == title;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            isHoveredMap[title] = true;
          });
        },
        onExit: (_) {
          setState(() {
            isHoveredMap[title] = false;
          });
        },
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            if (title == "Đăng xuất") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              );
            } else if (title == "Xóa tài khoản") {

              showDialog(
                context: context,
                builder: (context) => ConfirmDeleteAccountDialog(),
              );
            } else {
              setState(() {
                selectedMenu = title;
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isHoveredMap[title] == true
                  ? Colors.blue.shade100
                  : (isSelected ? Colors.blue.shade100 : Colors.transparent),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: Row(
              children: [
                Icon(icon, color: isLogout ? Colors.red : Colors.blue.shade700, size: 22),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: isLogout ? Colors.red : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //trái
  Widget leftSideWidget() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      height: MediaQuery.of(context).size.height - 170,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Căn lề trái
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150'), //link ảnh user
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nguyễn Văn A', // tên người dùng
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    Text(
                      'nguyenvana@example.com', // gmail
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Các nút chức năng
            buildMenuButtonWithIcon(Icons.info_outline, 'Thông tin tài khoản'),
            buildMenuButtonWithIcon(Icons.person_outline, 'Đổi tên'),
            buildMenuButtonWithIcon(Icons.image_outlined, 'Đổi ảnh đại diện'),
            buildMenuButtonWithIcon(Icons.email_outlined, 'Đổi Gmail'),
            buildMenuButtonWithIcon(Icons.email_outlined, 'Đổi Số điện thoại'),
            buildMenuButtonWithIcon(Icons.lock_outline, 'Đổi địa chỉ'),
            buildMenuButtonWithIcon(Icons.lock_outline, 'Đổi mật khẩu'),
            buildMenuButtonWithIcon(Icons.info, 'Giới thiệu'),
            buildMenuButtonWithIcon(Icons.delete_outline, 'Xóa tài khoản', isLogout: true),
            buildMenuButtonWithIcon(Icons.logout, 'Đăng xuất', isLogout: true),
          ],
        ),
      ),
    );
  }
  //phải
  Widget rightSideWidget() {
    return Container(
      width:  MediaQuery.of(context).size.width * 0.7 - 100,
      height: MediaQuery.of(context).size.height - 170,
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
      child: buildRightContent(),
      ),
    );
  }
  // thông tin
  Widget profile() {
    return ProfilePage(userId: 1,);
  }
  // Đổi tên
  Widget changeName() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Đổi tên', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
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
            onPressed: updateUserProfile,
            child: Text('Lưu thay đổi'),
          ),
        ],
      ),
    );
  }

  // Hàm chọn ảnh mới từ bộ chọn tệp
  Future<void> _pickImage() async {
    final XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      extensions: <String>['jpg', 'jpeg', 'png'],
    );

    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file != null) {
      setState(() {
        _newImagePath = file.path;  // Lưu đường dẫn ảnh mới
      });
    }
  }
  // Hàm xóa ảnh
  void _removeImage() {
    setState(() {
      _newImagePath = '';  // Xóa ảnh đã chọn
    });
  }
  Widget changeProfileImage() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Đổi ảnh đại diện', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              Column(
                children: [
                 // Ảnh cũ (URL)
                 Container(
                width: 150,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(_oldImageUrl),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
              ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        // Xử lý khi nhấn lưu thay đổi (ví dụ: lưu ảnh mới vào cơ sở dữ liệu)
                      },
                      child: Text('Lưu thay đổi'),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                children: [
                  // Ảnh mới (nếu có)
                  Stack(
                children: [
                  Container(
                    width: 150,
                    height: 200,
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
                        ? Center(child: Text('Chưa chọn ảnh', style: TextStyle(color: Colors.black54)))
                        : null,
                  ),
                  if (_newImagePath.isNotEmpty)
                    Positioned(
                      top: 5,
                      right: 5, // Di chuyển dấu X sang bên phải
                      child: GestureDetector(
                        onTap: _removeImage, // Xử lý xóa ảnh khi nhấn vào dấu X
                        child: CircleAvatar(
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
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: _pickImage, // Chọn ảnh mới từ file
                      child: Text('Chọn ảnh mới'),
                    ),
                  ),
                  ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Đổi Gmail
  Widget changeEmail() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Đổi Gmail', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildInfoRow('Email', 'nguyenvana@example.com'),
          const SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
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
            onPressed: updateUserProfile,
            child: Text('Lưu thay đổi'),
          ),
        ],
      ),
    );
  }

  // Đổi số điện thoại
  Widget changePhoneNumber() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Đổi số điện thoại', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildInfoRow('Số điện thoại', '+84 123 456 789'),
          const SizedBox(height: 20),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Số điện thoại mới',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập số điện thoại';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: updateUserProfile,
            child: Text('Lưu thay đổi'),
          ),
        ],
      ),
    );
  }

  // Đổi địa chỉ
  Widget changeAddress() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Đổi địa chỉ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildInfoRow('Địa chỉ', 'Hà Nội, Việt Nam'),
          const SizedBox(height: 20),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
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
            onPressed: updateUserProfile,
            child: Text('Lưu thay đổi'),
          ),
        ],
      ),
    );
  }

  // Đổi mật khẩu
  Widget changePassword() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Đổi mật khẩu', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
              border: OutlineInputBorder(),
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
              border: OutlineInputBorder(),
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
            onPressed: updateUserProfile,
            child: Text('Lưu thay đổi'),
          ),
        ],
      ),
    );
  }

  // Giới thiệu
  Widget introduction() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Giới thiệu', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text(
            'Đây là ứng dụng giúp bạn học tiếng anh Đây là ứng dụng giúp bạn học tiếng anh' +
                'Đây là ứng dụng giúp bạn học tiếng anh Đây là ứng dụng giúp bạn học tiếng anh'
                ,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Xử lý khi nhấn nút giới thiệu
            },
            child: Text('Tìm hiểu thêm'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Tên dòng (label)
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: TextField(
              controller: TextEditingController(text: value),
              enabled: false, // Không cho phép chỉnh sửa
              maxLines: null, // Cho phép nội dung xuống dòng tự động
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                border: InputBorder.none, // Không có viền
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// thông tin tải dữ liệu từ mysql trên railway về bằng node khi triển khai xong demo thôi xóa đi sửa lại
class ProfilePage extends StatefulWidget {
  final int userId;  // Thêm userId để xác định người dùng cần lấy thông tin

  ProfilePage({required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  late String fullName = '';
  late String email = '';
  late String phoneNumber = '';
  late String birthDate = '';
  late String address = '';

  final _userProfileService = UserProfileService();

  // Hàm lấy dữ liệu từ API hoặc MySQL
  Future<void> fetchUserData() async {
    try {
      // Gọi service để lấy dữ liệu người dùng từ MySQL
      var userData = await _userProfileService.getUser(widget.userId);

      if (userData != null) {
        setState(() {
          fullName = userData['fullName'] ?? '';
          email = userData['email'] ?? '';
          phoneNumber = userData['phoneNumber'] ?? '';
          birthDate = userData['birthDate'] ?? '';
          address = userData['address'] ?? '';
        });
      } else {
        // Nếu không có dữ liệu người dùng, hiển thị lỗi
        throw Exception('Không tìm thấy người dùng');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      throw Exception('Không thể tải dữ liệu');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Gọi hàm lấy dữ liệu khi trang được load
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(left: 100), // Cách ô bên trái 100
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh đại diện - Hình chữ nhật
            Container(
              width: 150,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://i.pravatar.cc/150'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            //const SizedBox(height: 10),

            _buildInfoRow('Họ và tên', fullName),
            _buildInfoRow('Email', email),
            _buildInfoRow('Số điện thoại', phoneNumber),
            _buildInfoRow('Ngày sinh', birthDate),
            _buildInfoRow('Địa chỉ', address),
          ],
        ),
      ),
    );
  }

  // Hàm xây dựng các dòng thông tin
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Đang tải...' : value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}


// xóa tài khoản
class ConfirmDeleteAccountDialog extends StatefulWidget {
  @override
  _ConfirmDeleteAccountDialogState createState() => _ConfirmDeleteAccountDialogState();
}
class _ConfirmDeleteAccountDialogState extends State<ConfirmDeleteAccountDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordValid = true;

  bool _checkPassword(String password) {
    return password == 'yourpassword';  // Thay 'yourpassword' bằng mật khẩu thực tế
  }

  // Xóa tài khoản
  void _deleteAccount() {
    if (_passwordController.text.isEmpty) {
      setState(() {
        _isPasswordValid = false;
      });
    } else if (_checkPassword(_passwordController.text)) {
      // Tiến hành xóa tài khoản
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tài khoản đã bị xóa!')),
      );
      Navigator.pop(context);  // Đóng hộp thoại xác nhận sau khi xóa
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RegisterScreen()),  // Sau khi xóa, chuyển về màn hình đăng ký
      );
    } else {
      setState(() {
        _isPasswordValid = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Xác nhận xóa tài khoản'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bạn có chắc muốn xóa tài khoản?'),
          const SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Nhập mật khẩu của bạn',
              errorText: _isPasswordValid ? null : 'Mật khẩu không đúng!',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);  // Đóng hộp thoại mà không làm gì thêm
          },
          child: Text('Hủy'),
        ),
        TextButton(
          onPressed: _deleteAccount,
          child: Text('OK'),
        ),
      ],
    );
  }
}

