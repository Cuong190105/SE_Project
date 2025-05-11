import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:eng_dictionary/core/services/user_service.dart';
import 'package:eng_dictionary/features/common/widgets/success_dialog.dart';
import 'package:eng_dictionary/features/common/widgets/error_dialog.dart';
import 'build_info_row.dart';

class ChangeImage extends StatelessWidget {
  final ValueNotifier<bool> isLoading;
  final ValueNotifier<String?> errorMessage;
  final ValueNotifier<String> profileImageUrl;
  final ValueNotifier<String> newImagePath;

  const ChangeImage({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.profileImageUrl,
    required this.newImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đổi ảnh đại diện',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 100,
                    height: 130,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(profileImageUrl.value),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Ảnh hiện tại',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              const SizedBox(width: 15),
              Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 130,
                        decoration: BoxDecoration(
                          image: newImagePath.value.isNotEmpty
                              ? DecorationImage(
                            image: FileImage(File(newImagePath.value)),
                            fit: BoxFit.cover,
                          )
                              : null,
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: newImagePath.value.isEmpty
                            ? const Center(
                          child: Text(
                            'Chưa chọn ảnh',
                            style: TextStyle(
                                color: Colors.black54, fontSize: 12),
                          ),
                        )
                            : null,
                      ),
                      if (newImagePath.value.isNotEmpty)
                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: _removeImage,
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.black54,
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Ảnh mới',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ],
          ),
          if (errorMessage.value != null) ...[
            const SizedBox(height: 10),
            Text(
              errorMessage.value!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                onPressed: isLoading.value ? null : () => _pickImage(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Chọn ảnh mới'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Hàm chọn ảnh mới từ bộ chọn tệp
  Future<void> _pickImage(BuildContext context) async {
    final XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      extensions: <String>['jpg', 'jpeg', 'png'],
    );

    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file != null) {
      // Update the new image path
      newImagePath.value = file.path;
      isLoading.value = true;
      errorMessage.value = null;

      final result = await UserService.updateAvatar(File(file.path));
      if (result['success']) {
        profileImageUrl.value = result['avatar'];
        newImagePath.value = '';
        SuccessDialog.show(context, 'Cập nhật ảnh đại diện thành công!');
      } else {
        errorMessage.value = result['message'];
      }
      isLoading.value = false;
    }
  }

  // Hàm xóa ảnh
  void _removeImage() {
    newImagePath.value = '';
  }
}
