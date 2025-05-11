import 'package:flutter/material.dart';
import 'package:eng_dictionary/core/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eng_dictionary/features/common/widgets/success_dialog.dart';
import 'package:eng_dictionary/features/common/widgets/error_dialog.dart';
import 'build_info_row.dart';

class ChangeEmail extends StatelessWidget {
  final ValueNotifier<String> oldEmail;
  final ValueNotifier<bool> isLoading;
  final ValueNotifier<String?> errorMessage;
  final TextEditingController newEmailController;

  const ChangeEmail({
    super.key,
    required this.oldEmail,
    required this.isLoading,
    required this.errorMessage,
    required this.newEmailController,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đổi Email',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<String>(
            valueListenable: oldEmail,
            builder: (context, value, _) => InfoRow(
              label: 'Email hiện tại',
              value: value,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: newEmailController,
            decoration: const InputDecoration(
              labelText: 'Email mới',
              border: OutlineInputBorder(),
            ),
          ),
          ValueListenableBuilder<String?>(
            valueListenable: errorMessage,
            builder: (context, value, _) => value != null
                ? Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(value, style: const TextStyle(color: Colors.red)),
            )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<bool>(
            valueListenable: isLoading,
            builder: (context, loading, _) => ElevatedButton(
              onPressed: loading ? null : () => _updateEmail(context),
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

  Future<void> _updateEmail(BuildContext context) async {
    final newEmail = newEmailController.text.trim();

    if (newEmail.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(newEmail)) {
      errorMessage.value = 'Vui lòng nhập email hợp lệ';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    final result = await UserService.changeEmail(newEmail);
    if (result['success']) {
      oldEmail.value = newEmail;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', newEmail);

      SuccessDialog.show(context, result['message']);
    } else {
      errorMessage.value = result['message'];
    }

    isLoading.value = false;
  }
}
