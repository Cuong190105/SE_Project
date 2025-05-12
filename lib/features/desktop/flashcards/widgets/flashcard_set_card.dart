import 'package:flutter/material.dart';
import 'package:eng_dictionary/data/models/flashcard_set.dart';
import 'package:eng_dictionary/data/models/flashcard_manager.dart';
import 'package:eng_dictionary/features/desktop/flashcards/screens/flashcard_detail.dart';
import 'package:eng_dictionary/features/common/widgets/error_dialog.dart';
import 'package:eng_dictionary/features/common/widgets/success_dialog.dart';
class FlashcardSetCard extends StatefulWidget {
  final VoidCallback loadData;
  final Function(String setId, String currentName) showRenameSetDialog;
  final int index;
  final ValueNotifier<List<FlashcardSet>> sets;

  const FlashcardSetCard({
    super.key,
    required this.loadData,
    required this.showRenameSetDialog,
    required this.index,
    required this.sets,
  });

  @override
  State<FlashcardSetCard> createState() => _FlashcardSetCardState();
}

class _FlashcardSetCardState extends State<FlashcardSetCard> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final set = widget.sets.value[widget.index];
    final color = set.color;

    return Stack(
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FlashcardDetailScreen(),
                  settings: RouteSettings(arguments: {'setId': set.id}),
                ),
              ).then((_) {
                 widget.loadData();
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.card_membership,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (value) {
                          if (value == 'rename') {
                            widget.showRenameSetDialog(set.id, set.name);
                          } else if (value == 'delete') {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Xóa bộ thẻ'),
                                content: Text('Bạn có chắc muốn xóa bộ "${set.name}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Hủy'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      setState(() => isLoading = true);
                                      try {
                                        // Xóa bộ thẻ
                                        await FlashcardManager.deleteSet(set.id);

                                        // Cập nhật lại danh sách bộ thẻ sau khi xóa
                                        widget.sets.value = await FlashcardManager.getSets();

                                        // Kiểm tra index hợp lệ trước khi gọi removeAt
                                        if (widget.index >= 0 && widget.index < widget.sets.value.length) {
                                          setState(() {
                                            widget.sets.value.removeAt(widget.index); // Xóa bộ thẻ từ danh sách

                                          });
                                        } else {
                                          // Xử lý nếu index không hợp lệ
                                          print('Index không hợp lệ: $widget.index');
                                        }

                                        // Đóng hộp thoại và hiển thị thông báo thành công
                                        Navigator.pop(context);
                                        SuccessDialog.show(context, 'Xóa bộ thẻ thành công');
                                      } catch (e) {
                                        setState(() => isLoading = false);
                                        ErrorDialog.show(context, 'Xóa bộ thẻ thất bại');
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Xóa'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'rename',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Đổi tên'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20),
                                SizedBox(width: 8),
                                Text('Xóa'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              set.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (set.isSample)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                'Mẫu',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${set.totalCards} thẻ',
                          style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: set.progressPercentage,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
