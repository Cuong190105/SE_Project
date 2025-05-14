import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:eng_dictionary/core/services/api_service.dart';

class Profile extends StatefulWidget  {
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
  State<Profile> createState() => _ProfileState();
}
class _ProfileState extends State<Profile> {
  
  Uint8List imageBytes = Uint8List(0);
  void _avatar() async {
    final img = await ApiService.get('user/avatar?avatar=$widget.profileImageUrl');
    setState(() {
      imageBytes = img;
    });
  }
  
  @override
  void initState() {
    _avatar();
    super.initState();
    //debugSharedPreferences();
  }
  
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
                image: MemoryImage(imageBytes),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(60),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildInfoRow('Họ và tên: ', widget.name.value),
        const SizedBox(height: 10),
        _buildInfoRow('Email: ', widget.email.value),
      ],
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)), // In đậm title
        Text(value,), // In đậm value
      ],
    );
  }
}
