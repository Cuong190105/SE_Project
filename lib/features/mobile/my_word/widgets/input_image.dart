import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class InputImage extends StatefulWidget {
  final ValueNotifier<List<Uint8List>> images;

  const InputImage({Key? key, required this.images}) : super(key: key);
  @override
  State<InputImage> createState() => _InputImageState();
}

class _InputImageState extends State<InputImage> {
  late ValueNotifier<List<Uint8List>> images;

  bool _isHovering = false;

  @override
  void initState() {
    images = widget.images;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickImage() async {
    late final XTypeGroup typeGroup;

    if (Platform.isAndroid) {
      typeGroup = const XTypeGroup(
        label: 'images_android',
        extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
      );
    } else if (Platform.isIOS) {
      // Enhanced iOS support with more mime types and UTIs
      typeGroup = const XTypeGroup(
        label: 'images_ios',
        mimeTypes: ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/heic'],
        uniformTypeIdentifiers: ['public.image', 'public.jpeg', 'public.png', 'com.compuserve.gif', 'public.heic'],
      );
    } else {
      typeGroup = const XTypeGroup(
        label: 'images',
        extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
        mimeTypes: ['image/jpeg', 'image/png', 'image/gif', 'image/webp'],
      );
    }

    try {
      final XFile? file = await openFile(
        acceptedTypeGroups: [typeGroup],
      );
      
      if (file != null) {
        final Uint8List bytes = await file.readAsBytes();
        setState(() {
          widget.images.value.add(bytes); // cập nhật dữ liệu gốc
          widget.images.notifyListeners(); // thông báo thay đổi
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      // Show error dialog or snackbar if needed
    }
  }

  void _removeImage(int index) {
    setState(() {
      widget.images.value.removeAt(index);
      widget.images.notifyListeners(); // cập nhật dữ liệu gốc
    });
  }

  @override
  Widget build(BuildContext context) {
    const double imageWidth = 120;
    const double imageHeight = 160;

    return ValueListenableBuilder<List<Uint8List>>(
      valueListenable: widget.images,
      builder: (context, images, _) {
        return Row(
          children: [
            SizedBox(width: 10),
            Expanded(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (int i = 0; i < images.length; i++)
                    Stack(
                      children: [
                        Container(
                          width: imageWidth,
                          height: imageHeight,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            color: Colors.grey.shade200,
                          ),
                          child: Image.memory(images[i], fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => _removeImage(i),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black54,
                              ),
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.close,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  MouseRegion(
                    onEnter: (_) => setState(() => _isHovering = true),
                    onExit: (_) => setState(() => _isHovering = false),
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: imageWidth,
                        height: imageHeight,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _isHovering
                                ? Colors.blue
                                : Colors.blue.shade100,
                            width: 2,
                          ),
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.add,
                            size: 40,
                            color: _isHovering
                                ? Colors.blue
                                : Colors.blue.shade100,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
