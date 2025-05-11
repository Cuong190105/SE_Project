import 'package:flutter/material.dart';

// Ô nhập văn bản
class LabeledTextField extends StatefulWidget {
  final String title;
  final TextEditingController? controller;
  final bool isEditing;
  final ValueChanged<bool> onEditingChanged;

  const LabeledTextField({
    Key? key,
    required this.title,
    this.controller,
    required this.isEditing,
    required this.onEditingChanged,
  }) : super(key: key);

  @override
  State<LabeledTextField> createState() => _LabeledTextFieldState();
}
class _LabeledTextFieldState extends State<LabeledTextField> {

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề ô nhập văn bản
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Ô nhập và nút phía dưới
        Expanded(
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: (screenWidth - 55) / 2,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade300, width: 2),
                    ),
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 48),
                    alignment: Alignment.topLeft,
                    child: TextField(
                      controller: widget.controller,
                      maxLines: null,
                      expands: true,
                      textAlign: TextAlign.start,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      //readOnly: !isEditing, // Chế độ chỉnh sửa hay không
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "",
                        isCollapsed: true,
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
        ),
      ],
    );
  }
}