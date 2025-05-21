import 'package:flutter/material.dart';
import 'dart:math';

class VocabularyCard extends StatefulWidget {
  final String word;
  final List<String> meaning;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const VocabularyCard({
    super.key,
    required this.word,
    required this.meaning,
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<VocabularyCard> createState() => _VocabularyCardState();
}

class _VocabularyCardState extends State<VocabularyCard> {
  bool _isHovered = false;
  late Color _headerColor;

  final List<Color> headerColors = [
    Colors.blue.shade900,
    Colors.red.shade900,
    Colors.purple.shade900,
    Colors.yellow.shade900,
    Colors.orange.shade900,
    Colors.green.shade900,
  ];

  @override
  void initState() {
    super.initState();
    _headerColor = (headerColors..shuffle()).first;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        height: screenHeight/3,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isHovered ? Colors.grey.shade200 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with random color
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _headerColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.word,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    color: Colors.white,
                    onSelected: (value) {
                      if (value == 'view' && widget.onView != null) {
                        widget.onView!();
                      } else if (value == 'edit' && widget.onEdit != null) {
                        widget.onEdit!();
                      } else if (value == 'delete' && widget.onDelete != null) {
                        widget.onDelete!();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'view',
                        child: Row(
                          children: const [
                            Icon(Icons.visibility, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Xem'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: const [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Sửa'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: const [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.grey, height: 1, thickness: 1),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  widget.meaning.join(' || '),
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 10,
                  softWrap: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
