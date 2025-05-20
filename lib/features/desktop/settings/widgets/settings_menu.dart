import 'package:flutter/material.dart';

class SettingsMenu extends StatelessWidget {
  final Function(String) onMenuSelected;

  const SettingsMenu({required this.onMenuSelected, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SettingsCategory(title: 'Tài khoản'),
        SettingsTile(
          icon: Icons.info_outline,
          title: 'Thông tin tài khoản',
          onTap: () => onMenuSelected('Thông tin tài khoản'),
        ),
        SettingsTile(
          icon: Icons.person_outline,
          title: 'Đổi tên',
          onTap: () => onMenuSelected('Đổi tên'),
        ),
        SettingsTile(
          icon: Icons.image_outlined,
          title: 'Đổi ảnh đại diện',
          onTap: () => onMenuSelected('Đổi ảnh đại diện'),
        ),
        SettingsTile(
          icon: Icons.email_outlined,
          title: 'Đổi Email',
          onTap: () => onMenuSelected('Đổi Email'),
        ),
        SettingsTile(
          icon: Icons.lock_outline,
          title: 'Đổi mật khẩu',
          onTap: () => onMenuSelected('Đổi mật khẩu'),
        ),
        const SizedBox(height: 16),
        SettingsCategory(title: 'Khác'),
        SettingsTile(
          icon: Icons.sync,
          title: 'Đồng bộ',
          onTap: () => onMenuSelected('Đồng bộ'),
        ),
        SettingsTile(
          icon: Icons.info,
          title: 'Giới thiệu',
          onTap: () => onMenuSelected('Giới thiệu'),
        ),
        SettingsTile(
          icon: Icons.logout,
          title: 'Đăng xuất',
          onTap: () => onMenuSelected('Đăng xuất'),
        ),
      ],
    );
  }
}

class SettingsCategory extends StatelessWidget {
  final String title;

  const SettingsCategory({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade700),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
