import 'package:flutter/material.dart';
import 'profile.dart';
import 'change_name.dart';
import 'change_image.dart';
import 'change_email.dart';
import 'change_password.dart';
import 'synchronize.dart';
import 'introduction.dart';

class RightSideContent extends StatelessWidget {
  final ValueNotifier<String> selectedMenu;
  final ValueNotifier<bool> isLoading;
  final ValueNotifier<String?> errorMessage;
  final ValueNotifier<String> name;
  final ValueNotifier<String> email;
  final ValueNotifier<String> profileImageUrl;
  final ValueNotifier<String> newImagePath;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController oldPasswordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController passwordController;

  const RightSideContent({
    super.key,
    required this.selectedMenu,
    required this.isLoading,
    required this.errorMessage,
    required this.name,
    required this.email,
    required this.profileImageUrl,
    required this.newImagePath,
    required this.nameController,
    required this.emailController,
    required this.oldPasswordController,
    required this.confirmPasswordController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: selectedMenu,
      builder: (context, selectedMenuValue, child) {
        Widget getContent() {
          switch (selectedMenuValue) {
            case 'Thông tin tài khoản':
              return Profile(name: name, email: email, profileImageUrl: profileImageUrl);
            case 'Đổi tên':
              return ChangeName(oldName: name, isLoading: isLoading, errorMessage: errorMessage, newNameController: nameController);
            case 'Đổi ảnh đại diện':
              return ChangeImage(isLoading: isLoading, errorMessage: errorMessage, profileImageUrl: profileImageUrl, newImagePath: newImagePath);
            case 'Đổi Email':
              return ChangeEmail(oldEmail: email, isLoading: isLoading, errorMessage: errorMessage, newEmailController: emailController);
            case 'Đổi mật khẩu':
              return ChangePassword(isLoading: isLoading, errorMessage: errorMessage, oldPasswordController: oldPasswordController, passwordController: passwordController, confirmPasswordController: confirmPasswordController);
            case 'Đồng bộ':
              return Synchronize(isLoading: isLoading, errorMessage: errorMessage);
            case 'Giới thiệu':
              return Introduction();
            default:
              return const Center(child: Text('Đang phát triển...', style: TextStyle(fontSize: 20)));
          }
        }

        return Container(
          width: MediaQuery.of(context).size.width * 0.7 - 100,
          height: MediaQuery.of(context).size.height - 170,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(child: getContent()),
        );
      },
    );
  }
}
