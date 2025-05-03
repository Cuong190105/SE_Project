import 'package:flutter/material.dart';
import '../screens_desktop/flashcard_models.dart';
import '../screens_desktop/flashcard_detail_screen.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  @override
  void initState() {
    super.initState();
    FlashcardManager.loadSampleData();
  }

  void _showCreateSetDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo bộ thẻ mới'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Tên bộ thẻ',
            hintText: 'Nhập tên cho bộ thẻ mới',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  FlashcardManager.createNewSet(nameController.text.trim());
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  void _showRenameSetDialog(String setId, String currentName) {
    final TextEditingController nameController =
        TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi tên bộ thẻ'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Tên bộ thẻ',
            hintText: 'Nhập tên mới cho bộ thẻ',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  FlashcardManager.renameSet(setId, nameController.text.trim());
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.white),
            onPressed: () {
              // Sort flashcard sets
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Bộ thẻ ghi nhớ của bạn',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${FlashcardManager.sets.length} bộ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount:
                  FlashcardManager.sets.length + 1, // sets + 1 add new button
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildAddNewSetCard(context);
                } else {
                  return _buildFlashcardSetCard(context, index - 1);
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: _showCreateSetDialog,
      ),
    );
  }

  Widget _buildAddNewSetCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue.shade200, width: 2),
      ),
      child: InkWell(
        onTap: _showCreateSetDialog,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, size: 40, color: Colors.blue.shade700),
            ),
            const SizedBox(height: 16),
            Text(
              'Thêm bộ mới',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashcardSetCard(BuildContext context, int index) {
    final set = FlashcardManager.sets[index];
    final color = set.color;

    return Card(
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
            // Refresh when returning from detail screen
            setState(() {});
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
                        _showRenameSetDialog(set.id, set.name);
                      } else if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Xóa bộ thẻ'),
                            content:
                                Text('Bạn có chắc muốn xóa bộ "${set.name}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Hủy'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    FlashcardManager.deleteSet(set.id);
                                  });
                                  Navigator.pop(context);
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
                  Text(
                    set.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
    );
  }
}
