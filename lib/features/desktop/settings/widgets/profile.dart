import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  final ValueNotifier<String> name;
  final ValueNotifier<String> email;
  final ValueNotifier<String> profileImageUrl;

  const Profile({
    required this.name,
    required this.email,
    required this.profileImageUrl,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                image: NetworkImage(profileImageUrl.value),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(60),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildInfoRow('Họ và tên', name.value),
        _buildInfoRow('Email', email.value),
      ],
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
