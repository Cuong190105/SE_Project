import 'package:flutter/material.dart';
import 'package:eng_dictionary/core/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eng_dictionary/features/common/widgets/success_dialog.dart';
import 'package:eng_dictionary/features/common/widgets/error_dialog.dart';
import 'build_info_row.dart';

class ChangePassword extends StatefulWidget {
  final ValueNotifier<bool> isLoading;
  final ValueNotifier<String?> errorMessage;
  final TextEditingController oldPasswordController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const ChangePassword({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.oldPasswordController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đổi mật khẩu',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: widget.oldPasswordController,
            obscureText: _obscureOldPassword,
            decoration: InputDecoration(
              labelText: 'Mật khẩu cũ',
              suffixIcon: IconButton(
                icon: Icon(_obscureOldPassword
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _obscureOldPassword = !_obscureOldPassword;
                  });
                },
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: widget.passwordController,
            obscureText: _obscureNewPassword,
            decoration: InputDecoration(
              labelText: 'Mật khẩu mới',
              suffixIcon: IconButton(
                icon: Icon(_obscureNewPassword
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: widget.confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Xác nhận mật khẩu',
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          ValueListenableBuilder<String?>(
            valueListenable: widget.errorMessage,
            builder: (context, value, _) => value != null
                ? Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                value,
                style: const TextStyle(color: Colors.red),
              ),
            )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<bool>(
            valueListenable: widget.isLoading,
            builder: (context, loading, _) => ElevatedButton(
              onPressed: loading ? null : () => _updatePassword(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Lưu thay đổi'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePassword(BuildContext context) async {
    final oldPwd = widget.oldPasswordController.text;
    final newPwd = widget.passwordController.text;
    final confirmPwd = widget.confirmPasswordController.text;

    if (oldPwd.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) {
      widget.errorMessage.value = 'Vui lòng điền đầy đủ thông tin';
      return;
    }
    if (newPwd != confirmPwd) {
      widget.errorMessage.value = 'Mật khẩu không khớp';
      return;
    }
    if (newPwd.length < 6) {
      widget.errorMessage.value = 'Mật khẩu mới phải có ít nhất 6 ký tự';
      return;
    }

    widget.isLoading.value = true;
    widget.errorMessage.value = null;

    final result =
    await UserService.changePassword(oldPwd, newPwd, confirmPwd);

    if (result['success']) {
      SuccessDialog.show(context, result['message']);
      widget.oldPasswordController.clear();
      widget.passwordController.clear();
      widget.confirmPasswordController.clear();
    } else {
      widget.errorMessage.value = result['message'];
    }

    widget.isLoading.value = false;
  }
}
