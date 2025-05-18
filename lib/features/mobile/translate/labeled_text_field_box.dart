import 'package:flutter/material.dart';
import 'package:eng_dictionary/features/desktop/vocabulary/vocabulary_detail.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

// Ô nhập văn bản
class LabeledTextField extends StatefulWidget {
  final TextEditingController? controller;
  final bool isEditing;
  final ValueChanged<bool> onEditingChanged;

  const LabeledTextField({
    Key? key,
    this.controller,
    required this.isEditing,
    required this.onEditingChanged,
  }) : super(key: key);

  @override
  State<LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<LabeledTextField> {
  Offset? _tapPosition;
  bool _isRightClick = false;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Flexible(
      fit: FlexFit.tight,
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                width: screenWidth - 32, // Full width minus padding
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade300, width: 2),
                ),
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 48),
                alignment: Alignment.topLeft,
                child: Listener(
                  onPointerDown: (event) {
                    // Check if it's a right-click
                    if (event.kind == PointerDeviceKind.mouse &&
                        event.buttons == kSecondaryMouseButton) {
                      _tapPosition = event.position;
                      _isRightClick =
                          true; // Flag to indicate right-click was pressed
                    }
                  },
                  onPointerUp: (event) async {
                    // Only show the menu if it was a right-click
                    if (_isRightClick &&
                        event.kind == PointerDeviceKind.mouse) {
                      final controller = widget.controller!;
                      final text = controller.text;
                      final selection = controller.selection;
                      final selectedText = selection.textInside(text);

                      final value = await showMenu<String>(
                        context: context,
                        position: RelativeRect.fromLTRB(
                          _tapPosition!.dx,
                          _tapPosition!.dy,
                          _tapPosition!.dx,
                          _tapPosition!.dy,
                        ),
                        items: const [
                          PopupMenuItem<String>(
                              value: 'cut', child: Text('Cắt')),
                          PopupMenuItem<String>(
                              value: 'copy', child: Text('Sao chép')),
                          PopupMenuItem<String>(
                              value: 'paste', child: Text('Dán')),
                          PopupMenuItem<String>(
                              value: 'selectAll', child: Text('Chọn toàn bộ')),
                          PopupMenuItem<String>(
                              value: 'translate', child: Text('Dịch')),
                        ],
                      );

                      switch (value) {
                        case 'cut':
                          if (selection.isValid && !selection.isCollapsed) {
                            Clipboard.setData(
                                ClipboardData(text: selectedText));
                            controller.text = selection.textBefore(text) +
                                selection.textAfter(text);
                            controller.selection = TextSelection.collapsed(
                                offset: selection.start);
                          }
                          break;

                        case 'copy':
                          if (selection.isValid && !selection.isCollapsed) {
                            Clipboard.setData(
                                ClipboardData(text: selectedText));
                          }
                          break;

                        case 'paste':
                          final data = await Clipboard.getData('text/plain');
                          if (data != null) {
                            controller.text = selection.textBefore(text) +
                                data.text! +
                                selection.textAfter(text);
                            final offset = selection.start + data.text!.length;
                            controller.selection =
                                TextSelection.collapsed(offset: offset);
                          }
                          break;

                        case 'selectAll':
                          controller.selection = TextSelection(
                              baseOffset: 0, extentOffset: text.length);
                          break;

                        case 'translate':
                          if (selection.isValid && !selection.isCollapsed) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Vocabulary(word: selectedText),
                              ),
                            );
                          }
                          break;
                      }

                      // Reset the right-click flag
                      _isRightClick = false;
                    }
                  },
                  child: TextField(
                    controller: widget.controller,
                    maxLines: null,
                    expands: true,
                    textAlign: TextAlign.start,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    contextMenuBuilder: (context, _) => const SizedBox.shrink(),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "",
                      isCollapsed: true,
                    ),
                  ),
                ),
              );
            },
          ),

          // Nút đặt dưới cùng bên trái của ô
          Positioned(
            bottom: 8,
            left: 8,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.translate),
                  tooltip: 'Dịch trực tiếp',
                  color: widget.isEditing ? Colors.blue : Colors.grey,
                  onPressed: () {
                    setState(() {
                      widget.onEditingChanged(true);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  tooltip: 'Chỉnh sửa',
                  color: !widget.isEditing ? Colors.blue : Colors.grey,
                  onPressed: () {
                    setState(() {
                      widget.onEditingChanged(false);
                    });
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
