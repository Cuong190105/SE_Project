import 'package:flutter/material.dart';
import 'package:eng_dictionary/data/models/flashcard_set.dart';
import 'package:eng_dictionary/data/models/flashcard_manager.dart';
import 'package:eng_dictionary/data/models/flashcard.dart';
import 'package:flutter/foundation.dart';
import 'package:eng_dictionary/features/common/widgets/back_button.dart';
import 'package:eng_dictionary/features/common/widgets/success_dialog.dart';
import 'package:eng_dictionary/features/common/widgets/error_dialog.dart';
import 'package:eng_dictionary/features/common/widgets/logo_small.dart';
class FlashcardDetailScreen extends StatefulWidget {
  const FlashcardDetailScreen({super.key});

  @override
  State<FlashcardDetailScreen> createState() => _FlashcardDetailScreenState();
}

class _FlashcardDetailScreenState extends State<FlashcardDetailScreen> {
  FlashcardSet? flashcardSet;
  int currentCardIndex = 0;
  bool _isFlipped = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFlashcardSet();
  }

  Future<void> _loadFlashcardSet() async {
    debugPrint('Đang tải bộ thẻ...');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final setId = args?['setId'] as String?;

      final sets = await FlashcardManager.getSets();
      if (sets.isEmpty) {
        debugPrint('Không có bộ thẻ nào cho người dùng hiện tại.');
        setState(() {
          _isLoading = false;
          _errorMessage = 'Chưa có bộ thẻ nào. Nhấn + để tạo bộ thẻ mới.';
        });
        return;
      }

      if (setId != null) {
        flashcardSet = sets.firstWhere(
              (set) => set.id == setId,
          orElse: () => sets.first,
        );
      } else {
        flashcardSet = sets.first;
      }

      debugPrint('Đã tải bộ thẻ: ${flashcardSet!.id}');
      setState(() {
        _isLoading = false;
        currentCardIndex = 0;
        _isFlipped = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Lỗi tải bộ thẻ: $e\n$stackTrace');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Không thể tải bộ thẻ. Vui lòng kiểm tra kết nối và thử lại.';
      });
    }
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _showAddCardDialog() {
    final TextEditingController frontController = TextEditingController();
    final TextEditingController backController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm thẻ mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: frontController,
              decoration: const InputDecoration(
                labelText: 'Mặt trước (Tiếng Anh)',
                hintText: 'Nhập từ hoặc câu tiếng Anh',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: backController,
              decoration: const InputDecoration(
                labelText: 'Mặt sau (Nghĩa)',
                hintText: 'Nhập nghĩa của từ hoặc câu',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (flashcardSet == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng tạo bộ thẻ trước')),
                );
                Navigator.pop(context);
                return;
              }
              if (frontController.text.trim().isNotEmpty &&
                  backController.text.trim().isNotEmpty) {
                setState(() {
                  _isLoading = true;
                });
                try {
                  await FlashcardManager.addCardToSet(
                    flashcardSet!.id,
                    frontController.text.trim(),
                    backController.text.trim(),
                  );
                  await _loadFlashcardSet();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thêm thẻ thành công')),
                  );
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi thêm thẻ: $e')),
                  );
                }
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showEditCardDialog(Flashcard card) {
    final TextEditingController frontController =
    TextEditingController(text: card.frontContent);
    final TextEditingController backController =
    TextEditingController(text: card.backContent);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa thẻ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: frontController,
              decoration: const InputDecoration(
                labelText: 'Mặt trước (Tiếng Anh)',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: backController,
              decoration: const InputDecoration(
                labelText: 'Mặt sau (Nghĩa)',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (frontController.text.trim().isNotEmpty &&
                  backController.text.trim().isNotEmpty) {
                setState(() {
                  _isLoading = true;
                });
                try {
                  await FlashcardManager.updateCard(
                    flashcardSet!.id,
                    card.id,
                    frontController.text.trim(),
                    backController.text.trim(),
                  );
                  await _loadFlashcardSet();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chỉnh sửa thẻ thành công')),
                  );
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi chỉnh sửa thẻ: $e')),
                  );
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showRenameSetDialog() {
    final TextEditingController nameController =
    TextEditingController(text: flashcardSet?.name ?? '');

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
            onPressed: () async {
              if (flashcardSet == null) {
                Navigator.pop(context);
                return;
              }
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  _isLoading = true;
                });
                try {
                  await FlashcardManager.renameSet(
                    flashcardSet!.id,
                    nameController.text.trim(),
                  );
                  await _loadFlashcardSet();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đổi tên bộ thẻ thành công')),
                  );
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi đổi tên: $e')),
                  );
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Color lighten(Color color, [double amount = 0.2]) {
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadFlashcardSet,
                child: Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (flashcardSet == null) {
      return Scaffold(
        body: Center(child: Text('Không tìm thấy bộ thẻ')),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue.shade700,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: null, // Vô hiệu hóa nút khi không có bộ thẻ
        ),
      );
    }

    final color = flashcardSet!.color;
    final totalCards = flashcardSet!.totalCards;

    return Scaffold(
      appBar: AppBar(

        backgroundColor: lighten(color, 0.2),
        elevation: 0,
        leadingWidth: screenWidth,
        leading: Stack(
        children: [
          CustomBackButton_(content: flashcardSet!.name, color: color,),
          Center(
            child: LogoSmall(),
          ),
        ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _showRenameSetDialog,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'manage') {
                _showManageCardsDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'manage',
                child: Row(
                  children: [
                    Icon(Icons.list, size: 20),
                    SizedBox(width: 8),
                    Text('Quản lý thẻ'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
            stops: const [0.3, 1.0],
          ),
        ),
    child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    totalCards > 0
                        ? 'Thẻ ${currentCardIndex + 1} / $totalCards'
                        : 'Chưa có thẻ nào',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
                if (totalCards > 0)
                  Text(
                    'Nhấn để lật thẻ',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: totalCards > 0 ?
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child:  Row (
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: currentCardIndex > 0
                              ? () {
                            setState(() {
                              currentCardIndex--;
                              _isFlipped = false;
                            });
                          }
                              : null,
                          icon: const Icon(Icons.arrow_back_ios, size: 16),
                          label: const Text('Trước'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                        _buildFlashcard(color),
                        ElevatedButton.icon(
                          onPressed: currentCardIndex < totalCards - 1
                              ? () {
                            setState(() {
                              currentCardIndex++;
                              _isFlipped = false;
                            });
                          }
                              : null,
                          icon: const Icon(Icons.arrow_forward_ios, size: 16),
                          label: const Text('Tiếp'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                    )
                : _buildEmptyState(color),
          ),
          if (totalCards > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Column(
                  children: [
                    Text(
                      totalCards > 0
                          ? 'Thẻ ${currentCardIndex + 1} / $totalCards'
                          : 'Chưa có thẻ nào',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        min(5, totalCards),
                            (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == currentCardIndex % min(5, totalCards)
                                ? color
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: color,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: flashcardSet == null ? null : _showAddCardDialog,
      ),
    );
  }

  Widget _buildFlashcard(Color color) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    if (flashcardSet!.cards.isEmpty) {
      return _buildEmptyState(color);
    }

    if (currentCardIndex >= flashcardSet!.cards.length) {
      currentCardIndex = flashcardSet!.cards.length - 1;
    }

    final card = flashcardSet!.cards[currentCardIndex];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: GestureDetector(
        onTap: _flipCard,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: color.withOpacity(0.5), width: 2),
          ),
          child: Container(
            width: screenWidth/1.5,
            height: screenHeight/1.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, color.withOpacity(0.1)],
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isFlipped ? Icons.translate : Icons.text_fields,
                          size: 48,
                          color: color,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _isFlipped ? card.backContent : card.frontContent,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        if (_isFlipped)
                          Text(
                            'Nhấn để xem từ tiếng Anh',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          )
                        else
                          Text(
                            'Nhấn để xem nghĩa',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: color,
                    ),
                    onPressed: () => _showEditCardDialog(card),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Checkbox(
                    value: card.isLearned,
                    activeColor: color,
                    onChanged: (value) async {
                      setState(() {
                        _isLoading = true;
                      });
                      try {
                        await FlashcardManager.markCardAsLearned(
                          flashcardSet!.id,
                          card.id,
                          value ?? false,
                        );
                        await _loadFlashcardSet();
                      } catch (e) {
                        setState(() {
                          _isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi đánh dấu thẻ: $e')),
                        );
                      }
                    },
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Text(
                    'Đã học',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add,
            size: 80,
            color: color.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có thẻ nào',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút + để thêm thẻ mới',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _showManageCardsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quản lý thẻ - ${flashcardSet!.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: flashcardSet!.cards.isEmpty
              ? const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('Chưa có thẻ nào'),
            ),
          )
              : ListView.builder(
            shrinkWrap: true,
            itemCount: flashcardSet!.cards.length,
            itemBuilder: (context, index) {
              final card = flashcardSet!.cards[index];
              return ListTile(
                title: Text(
                  card.frontContent,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  card.backContent,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditCardDialog(card);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          await FlashcardManager.deleteCard(
                            flashcardSet!.id,
                            card.id,
                          );
                          await _loadFlashcardSet();
                          Navigator.pop(context);
                          SuccessDialog.show(context, 'Xóa thẻ thành công');
                        } catch (e) {
                          setState(() {
                            _isLoading = false;
                          });
                          ErrorDialog.show(context, 'Lỗi xóa thẻ');
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  int min(int a, int b) {
    return a < b ? a : b;
  }
}