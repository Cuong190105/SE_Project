import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:eng_dictionary/core/services/user_service.dart';
import 'package:eng_dictionary/features/common/widgets/success_dialog.dart';
import 'package:eng_dictionary/features/common/widgets/error_dialog.dart';
import 'build_info_row.dart';
import 'dart:typed_data';
import 'package:eng_dictionary/core/services/api_service.dart';
class ChangeImage extends StatefulWidget {
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
  _ChangeImageState createState() => _ChangeImageState();
}
class _ChangeImageState extends State<ChangeImage> {

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
                    width: 150,
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: MemoryImage(imageBytes),
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
                        width: 150,
                        height: 200,
                        decoration: BoxDecoration(
                          image: widget.newImagePath.value.isNotEmpty
                              ? DecorationImage(
                            image: FileImage(File(widget.newImagePath.value)),
                            fit: BoxFit.cover,
                          )
                              : null,
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: widget.newImagePath.value.isEmpty
                            ? const Center(
                          child: Text(
                            'Chưa chọn ảnh',
                            style: TextStyle(
                                color: Colors.black54, fontSize: 12),
                          ),
                        )
                            : null,
                      ),
                      if (widget.newImagePath.value.isNotEmpty)
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
          if (widget.errorMessage.value != null) ...[
            const SizedBox(height: 10),
            Text(
              widget.errorMessage.value!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed:  () => _pickImage(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
                child: const Text('chọn ảnh mới'),
              ),
              const SizedBox(width: 45),

              ValueListenableBuilder<bool>(
                valueListenable: widget.isLoading,
                builder: (context, loading, _) =>
                    ElevatedButton(
                      onPressed: loading ? null : () => _updateAvatar(context),
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
        ],
      ),
    );
  }

  // Hàm chọn ảnh mới từ bộ chọn tệp
  Future<void> _updateAvatar(BuildContext context) async {

    if (widget.newImagePath.value.isNotEmpty) {
      // Update the new image path
      widget.isLoading.value = true;
      widget.errorMessage.value = null;

      final result = await UserService.updateAvatar(File(widget.newImagePath.value));
      if (result['success']) {
        widget.profileImageUrl.value = result['avatar'];
        widget.newImagePath.value = '';
        SuccessDialog.show(context, 'Cập nhật ảnh đại diện thành công!');
      } else {
        widget.errorMessage.value = result['message'];
      }
      widget.isLoading.value = false;
    }
  }

  Future<void> _pickImage() async {
    try {
      // Use image_picker for mobile platforms (Android and iOS)
      if (Platform.isAndroid || Platform.isIOS) {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80, // Reduce image quality to save space
        );
        
        if (image != null) {
          setState(() {
            widget.newImagePath.value = image.path;
          });
        }
      } 
      // Use file_selector for desktop platforms
      else {
        final XTypeGroup typeGroup = XTypeGroup(
          label: 'images',
          extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
          mimeTypes: ['image/jpeg', 'image/png', 'image/gif', 'image/webp'],
        );

        final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);

        if (file != null) {
          setState(() {
            widget.newImagePath.value = file.path;
          });
        }
      }
    } catch (e) {
      // Handle any errors that might occur during image picking
      setState(() {
        widget.errorMessage.value = 'Không thể chọn ảnh: ${e.toString()}';
      });
    }
  }
  // Hàm xóa ảnh
  void _removeImage() {
    setState(() {
      widget.newImagePath.value = '';
    });
  }
}
