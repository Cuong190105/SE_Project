import 'package:flutter/material.dart';

class VocabularyCard extends StatelessWidget {
  final String word;
  final List<String> meaning;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const VocabularyCard({
    Key? key,
    required this.word,
    required this.meaning,
    this.onView,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Container(
      height: 150,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  word,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'view' && onView != null) {
                    onView!();
                  } else if (value == 'edit' && onEdit != null) {
                    onEdit!();
                  } else if (value == 'delete' && onDelete != null) {
                    onDelete!();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text('Xem'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text('Sửa'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        const SizedBox(width: 8),
                        const Text('Xóa'),
                      ],
                    ),
                  ),
                ],
              ),

            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              (meaning as List).join(' || '),
              style: const TextStyle(fontSize: 16),
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