import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:file_selector/file_selector.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:mysql1/mysql1.dart';
import 'package:eng_dictionary/features/desktop/home/home_screen.dart';
import 'package:eng_dictionary/features/common/widgets/logo_small.dart';
import 'package:eng_dictionary/features/common/widgets/back_button.dart';
import 'package:eng_dictionary/features/common/widgets/streak_count.dart';
import 'package:eng_dictionary/features/desktop/settings/widgets/left_side.dart';
import 'package:eng_dictionary/features/desktop/settings/widgets/right_side.dart';
//import '../screens_phone/authentic_phone/login_screen_phone.dart';
import 'package:eng_dictionary/core/services/user_service.dart';
import 'package:eng_dictionary/core/services/user_service.dart';
import 'package:eng_dictionary/data/models/flashcard_set.dart';
import 'package:eng_dictionary/data/models/flashcard_manager.dart';
import 'package:eng_dictionary/data/models/flashcard.dart';


class Settings extends StatefulWidget {
  final String userEmail;

  Settings({required this.userEmail});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  ValueNotifier<String> _name = ValueNotifier<String>('Unknown Name');
  ValueNotifier<String> _email = ValueNotifier<String>('unknown_user@example.com');
  ValueNotifier<String> _profileImageUrl = ValueNotifier<String>(
      'https://i.pravatar.cc/150');
  ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessage = ValueNotifier<String?>(null);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  ValueNotifier<String> selectedMenu = ValueNotifier<String>(
      'Thông tin tài khoản');
  ValueNotifier<String> _newImagePath = ValueNotifier<String>('');
  Map<String, bool> isHoveredMap = {};

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    selectedMenu.value = 'Thông tin tài khoản';
  }

  Future<void> _fetchUserInfo() async {
    setState(() {
      _isLoading.value = true;
      _errorMessage.value = null;
    });
    final result = await UserService.getUserInfo();

    if (result['success']) {
      setState(() {
        print(result['data']['name'] ?? 'Unknown');
        _name.value = result['data']['name'] ?? 'Unknown';
        _email.value = result['data']['email'] ?? 'Unknown';
        _profileImageUrl = result['data']['avatar'] ?? _profileImageUrl;
        _nameController.text = _name.value;
        _emailController.text = _email.value;
      });
    } else {
      setState(() {
        _errorMessage.value = result['message'];
      });
    }
    setState(() {
      _isLoading.value = false;
    });
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    int streakCount = 5; // Đợi dữ liệu từ database

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
        leadingWidth: screenWidth,
        leading: Stack(
          children: [
            Center(
              child: LogoSmall(),
            ),
          ],
        ),
        actions: [
          StreakCount(),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: CustomBackButton(content: 'Cài đặt'),
                        ),
                      ),
              const SizedBox(height: 10),

              Row(
                  children: [
                    LeftSideMenu(selectedMenu: selectedMenu,
                        name: _name,
                        email: _email,),
                    RightSideContent(
                      selectedMenu: selectedMenu,
                      isLoading: _isLoading,
                      errorMessage: _errorMessage,
                      name: _name,
                      email: _email,
                      profileImageUrl: _profileImageUrl,
                      newImagePath: _newImagePath,
                      nameController: _nameController,
                      emailController: _emailController,
                      oldPasswordController: _oldPasswordController,
                      confirmPasswordController: _confirmPasswordController,
                      passwordController: _passwordController,
                    ),
                  ]
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
/*
  Widget buildRightContent() {
    switch (selectedMenu) {
      case 'Thông tin tài khoản':
        return profile();  // Widget thông tin tài khoản
      case 'Đổi tên':
        return changeName();  // Widget đổi tên
      case 'Đổi ảnh đại diện':
        return changeProfileImage();  // Widget đổi ảnh đại diện
      case 'Đổi Email':
        return changeEmail();  // Widget đổi Email
      case 'Đổi địa chỉ':
        return changeAddress();  // Widget đổi địa chỉ
      case 'Đổi mật khẩu':
        return changePassword(); // Widget đổi mật khẩu
      case 'Đồng bộ':
        return synchronize(); // Widget đồng bộ
      case 'Giới thiệu':
        return introduction();  // Widget giới thiệu
      default:
        return Center(child: Text('Đang phát triển...', style: TextStyle(fontSize: 20)));
    }
  }
/* //tạo nút Menu bên trái
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
            /*if (isLogout) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              );
            } else {
              setState(() {
                selectedMenu = title;
              });
            }*/
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
      child:  SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150'), //link ảnh user
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_nameDataController.text==''||_emailDataController.text=='')
                        ...[
                          CircularProgressIndicator(),
                        ]
                       else
                        ...[
                        Text(
                            _nameDataController.text, // tên người dùng
                            style: TextStyle(fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                          Text(
                            _emailDataController.text, // Email
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade600),
                          ),
                        ]

                    ],
                  ),
                ]
              ),
              const SizedBox(height: 10),

            // Các nút chức năng
            buildMenuButtonWithIcon(Icons.info_outline, 'Thông tin tài khoản'),
            buildMenuButtonWithIcon(Icons.person_outline, 'Đổi tên'),
            buildMenuButtonWithIcon(Icons.image_outlined, 'Đổi ảnh đại diện'),
            buildMenuButtonWithIcon(Icons.email_outlined, 'Đổi Email'),
            buildMenuButtonWithIcon(Icons.location_on, 'Đổi địa chỉ'),
            buildMenuButtonWithIcon(Icons.lock_outline, 'Đổi mật khẩu'),
            buildMenuButtonWithIcon(Icons.info, 'Giới thiệu'),
            buildMenuButtonWithIcon(Icons.sync, 'Đồng bộ'),
            buildMenuButtonWithIcon(Icons.logout, 'Đăng xuất', isLogout: true),

            ],
          ),
      ),
    );
  }
*/
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
          _buildInfoRow('Họ và tên', _nameDataController.text),
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

  // Đổi Email
  Widget changeEmail() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Đổi Email', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildInfoRow('Email', _emailDataController.text),
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

  // Đổi địa chỉ
  Widget changeAddress() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Đổi địa chỉ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildInfoRow('Địa chỉ', _addressDataController.text),
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
    String _message = ''; // Biến lưu thông báo
    Color _messageColor = Colors.black; // Màu mặc định cho thông báo

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Đổi mật khẩu', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Thêm ô nhập mật khẩu cũ
          TextFormField(
            controller: _oldPasswordController,
            obscureText: _obscureOldPassword,
            decoration: InputDecoration(
              labelText: 'Mật khẩu cũ',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureOldPassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureOldPassword = !_obscureOldPassword;
                  });
                },
              ),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu cũ';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),

          // Mật khẩu mới
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

          // Xác nhận mật khẩu
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

          // Nút lưu thay đổi
          ElevatedButton(
            onPressed: () {
              // Kiểm tra tính hợp lệ và cập nhật thông báo
              if (_oldPasswordController.text.isEmpty ||
                  _passwordController.text.isEmpty ||
                  _confirmPasswordController.text.isEmpty) {
                setState(() {
                  _message = 'Vui lòng điền đầy đủ thông tin mật khẩu';
                  _messageColor = Colors.red;
                });
              } else if (_passwordController.text != _confirmPasswordController.text) {
                setState(() {
                  _message = 'Mật khẩu không khớp';
                  _messageColor = Colors.red;
                });
              } else {
                // Thực hiện lưu thay đổi và thông báo thành công
                setState(() {
                  _message = 'Đổi mật khẩu thành công';
                  _messageColor = Colors.blue;
                });
                updateUserProfile();
              }
            },
            child: Text('Lưu thay đổi'),
          ),
          const SizedBox(height: 10),

          // Hiển thị thông báo
          Text(
            _message,
            style: TextStyle(color: _messageColor, fontWeight: FontWeight.bold),
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

  // hàm tải lại dữ liệu ở đây
  Widget synchronize() {
    return Center(
      child: FutureBuilder<void>(
        future: fetchDataFromDatabase(), // Dữ liệu sẽ được tải từ đây
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Nếu đang tải, hiển thị vòng quay loading
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Nếu có lỗi, hiển thị thông báo lỗi
            return Text("Đã có lỗi xảy ra: ${snapshot.error}");
          } else if (snapshot.connectionState == ConnectionState.done) {
            // Khi dữ liệu đã được tải xong, hiển thị các form điền thông tin
            return Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Dữ liệu của bạn đã được cập nhật thành công'),
                ),
              ],
            );
          } else {
            return Text('Không có dữ liệu');
          }
        },
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
}*/

