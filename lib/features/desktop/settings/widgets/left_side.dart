import 'package:flutter/material.dart';
import 'package:eng_dictionary/features/common/screens/register_screen.dart';
class LeftSideMenu extends StatefulWidget {
  final ValueNotifier<String> selectedMenu;
  final TextEditingController nameController;
  final TextEditingController emailController;

  const LeftSideMenu({
    super.key,
    required this.selectedMenu,
    required this.nameController,
    required this.emailController,
  });

  @override
  State<LeftSideMenu> createState() => _LeftSideMenuState();
}

class _LeftSideMenuState extends State<LeftSideMenu> {
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreenDesktop()),
              );
            } else {
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
                    if (widget.nameController.text.isEmpty || widget.emailController.text.isEmpty)
                      const CircularProgressIndicator()
                    else ...[
                      Text(
                        widget.nameController.text,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        widget.emailController.text,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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
