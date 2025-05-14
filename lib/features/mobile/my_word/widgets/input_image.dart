import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';

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
    final XFile? file = await openFile(
      acceptedTypeGroups: [XTypeGroup(label: 'images', extensions: ['jpg', 'png', 'jpeg'])],
    );
    if (file != null) {
      final Uint8List bytes = await file.readAsBytes();
      setState(() {
        widget.images.value.add(bytes); // cập nhật dữ liệu gốc
        widget.images.notifyListeners(); // thông báo thay đổi
      });
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
            SizedBox(width: 100),
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
                              child: Icon(Icons.close, color: Colors.white, size: 16),
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
                            color: _isHovering ? Colors.blue : Colors.blue.shade100,
                            width: 2,
                          ),
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.add,
                            size: 40,
                            color: _isHovering ? Colors.blue : Colors.blue.shade100,
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