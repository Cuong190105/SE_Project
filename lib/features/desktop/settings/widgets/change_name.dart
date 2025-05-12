import 'package:flutter/material.dart';
import 'package:eng_dictionary/core/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eng_dictionary/features/common/widgets/success_dialog.dart';
import 'package:eng_dictionary/features/common/widgets/error_dialog.dart';
import 'build_info_row.dart';
import 'package:eng_dictionary/features/common/widgets/success_dialog.dart';
class ChangeName extends StatelessWidget {
  final ValueNotifier<String> oldName;
  final ValueNotifier<bool> isLoading;
  final ValueNotifier<String?> errorMessage;
  final TextEditingController newNameController;

  const ChangeName({
    super.key,
    required this.oldName,
    required this.isLoading,
    required this.errorMessage,
    required this.newNameController,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đổi tên',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<String>(
            valueListenable: oldName,
            builder: (context, value, _) =>
                InfoRow(label: 'Họ và tên', value: value),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: newNameController,
            decoration: const InputDecoration(
              labelText: 'Họ và tên mới',
              border: OutlineInputBorder(),
            ),
          ),
          ValueListenableBuilder<String?>(
            valueListenable: errorMessage,
            builder: (context, value, _) =>
            value != null
                ? Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(value, style: const TextStyle(color: Colors.red)),
            )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<bool>(
            valueListenable: isLoading,
            builder: (context, loading, _) =>
                ElevatedButton(
                  onPressed: loading ? null : () => _updateName(context),
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

  Future<void> _updateName(BuildContext context) async {
    final newName = newNameController.text.trim();
    if (newName.isEmpty) {
      errorMessage.value = 'Vui lòng nhập tên';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await UserService.changeName(newName);
      if (result['success']) {
        oldName.value = newName;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', newName);

        SuccessDialog.show(context, result['message']);
      } else {
        errorMessage.value = result['message'];
      }
    } catch (e) {
      errorMessage.value = 'Lỗi xảy ra: $e';
    } finally {
      isLoading.value = false;
    }
  }
}

