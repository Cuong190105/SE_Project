import 'package:flutter/material.dart';
import 'package:eng_dictionary/features/common/screens/login_screen.dart';
import 'package:eng_dictionary/data/models/database_helper.dart';
import 'package:eng_dictionary/core/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eng_dictionary/core/services/api_service.dart';

class LeftSideMenu extends StatefulWidget {
  final ValueNotifier<String> selectedMenu;
  final ValueNotifier<String> name;
  final ValueNotifier<String> email;

  const LeftSideMenu({
    super.key,
    required this.selectedMenu,
    required this.name,
    required this.email,
  });

  @override
  State<LeftSideMenu> createState() => _LeftSideMenuState();
}

class _LeftSideMenuState extends State<LeftSideMenu> {
  late Future<Map<String, dynamic>?> _userFuture;
  late Future<String?> _userName;
  late Future<String?> _userEmail;
  Map<String, bool> isHoveredMap = {};

  Widget buildMenuButtonWithIcon(IconData icon, String title, {bool isLogout = false}) {
    bool isSelected = widget.selectedMenu.value == title;

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
            if (isLogout) {
              showDialog(
                context: context,
                barrierDismissible: false, // không cho phép đóng bằng cách bấm ngoài hộp thoại
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Xác nhận"),
                    content: Text("Bạn có muốn đăng xuất?"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Đóng hộp thoại
                        },
                        child: Text("Hủy"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Đóng hộp thoại
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: Text("Đăng xuất"),
                      ),
                    ],
                  );
                },
              );
            }
            else {
              setState(() {
                widget.selectedMenu.value = title;
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

  void debugSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    if (keys.isEmpty) {
      debugPrint('SharedPreferences đang rỗng.');
    } else {
      for (var key in keys) {
        final value = prefs.get(key);
        debugPrint('[$key] = $value');
      }
    }
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await ApiService.get('users');

      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy danh sách người dùng: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _userName = AuthService.getUserName();
    _userEmail = AuthService.getUserEmail();
    _userFuture = Future.wait([_userName, _userEmail]).then((values) {
      return {
        'name': values[0] ,
        'email': values[1] ,
      };
    });
    //debugSharedPreferences();

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      height: MediaQuery.of(context).size.height - 170,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.name.value.isEmpty || widget.email.value.isEmpty)
                      const CircularProgressIndicator()
                    else ...[
                      Text(
                        widget.name.value,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),

                      Text(
                        widget.email.value,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Menu buttons
            buildMenuButtonWithIcon(Icons.info_outline, 'Thông tin tài khoản'),
            buildMenuButtonWithIcon(Icons.person_outline, 'Đổi tên'),
            buildMenuButtonWithIcon(Icons.image_outlined, 'Đổi ảnh đại diện'),
            buildMenuButtonWithIcon(Icons.email_outlined, 'Đổi Email'),
            buildMenuButtonWithIcon(Icons.lock_outline, 'Đổi mật khẩu'),
            buildMenuButtonWithIcon(Icons.info, 'Giới thiệu'),
            buildMenuButtonWithIcon(Icons.sync, 'Đồng bộ'),
            buildMenuButtonWithIcon(Icons.logout, 'Đăng xuất', isLogout: true),
          ],
        ),
      ),
    );
  }
}
