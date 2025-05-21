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
  late Color _headerColor;

  final List<Color> headerColors = [
    Colors.blue.shade900,
    Colors.red.shade900,
    Colors.purple.shade900,
    Colors.orange.shade900,
    Colors.green.shade900,
    Colors.teal.shade900,
  ];

  @override
  void initState() {
    super.initState();
    _headerColor = (headerColors..shuffle()).first;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.word,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.white, size: 20),
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
                          Icon(Icons.visibility, color: Colors.green, size: 18),
                          SizedBox(width: 8),
                          Text('Xem', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: const [
                          Icon(Icons.edit, color: Colors.blue, size: 18),
                          SizedBox(width: 8),
                          Text('Sửa', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: const [
                          Icon(Icons.delete, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Text('Xóa', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(color: Colors.grey, height: 1, thickness: 1),

          // Content
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              widget.meaning.join(' || '),
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
