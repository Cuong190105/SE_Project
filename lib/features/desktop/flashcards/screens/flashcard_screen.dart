import 'package:flutter/material.dart';
import 'package:eng_dictionary/data/models/flashcard_set.dart';
import 'package:eng_dictionary/data/models/flashcard_manager.dart';
import 'package:eng_dictionary/data/models/flashcard.dart';
import 'flashcard_detail.dart';
import 'package:flutter/foundation.dart';
import 'package:eng_dictionary/features/desktop/flashcards/widgets/add_set_card.dart';
import 'package:eng_dictionary/features/desktop/flashcards/widgets/flashcard_set_card.dart';
import 'package:eng_dictionary/features/common/widgets/streak_count.dart';
import 'package:eng_dictionary/features/mobile/settings/widgets/setting_button.dart';
import 'package:eng_dictionary/features/common/widgets/logo_small.dart';
import 'package:eng_dictionary/features/common/widgets/back_button.dart';
import 'package:eng_dictionary/features/common/widgets/error_dialog.dart';
import 'package:eng_dictionary/features/common/widgets/success_dialog.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  ValueNotifier<bool> _isLoading =  ValueNotifier<bool>(true);
  ValueNotifier<List<FlashcardSet>> _sets =  ValueNotifier<List<FlashcardSet>>([]);
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    debugPrint('Loading flashcard data...');
    setState(() {
      _isLoading.value = true;
      _errorMessage = null;
    });
    try {
      await FlashcardManager.syncOnStartup().timeout(
        Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Sync on startup timed out');
          throw Exception('Không thể đồng bộ với server');
        },
      );
      _sets.value = await FlashcardManager.getSets();
      debugPrint('Loaded ${_sets.value.length} flashcard sets');
      setState(() {
        _isLoading.value = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Error loading flashcard data: $e\n$stackTrace');
      setState(() {
        _isLoading.value = false;
        _errorMessage = 'Lỗi tải dữ liệu: $e';
      });
    }
  }

  void _showCreateSetDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo bộ thẻ mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Tên bộ thẻ',
                hintText: 'Nhập tên cho bộ thẻ mới',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                hintText: 'Nhập mô tả cho bộ thẻ',
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
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  _isLoading.value = true;
                });
                try {
                  await FlashcardManager.createNewSet(
                    nameController.text.trim(),
                    descController.text.trim(),
                  );
                  _sets.value = await FlashcardManager.getSets();
                  setState(() {
                    _isLoading.value = false;
                  });
                  Navigator.pop(context);
                  SuccessDialog.show(context, 'Tạo bộ thẻ thành công');
                } catch (e) {
                  setState(() {
                    _isLoading.value = false;
                  });
                 ErrorDialog.show(context, 'Lỗi tạo bộ thẻ');
                }
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
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  _isLoading.value = true;
                });
                try {
                  await FlashcardManager.renameSet(setId, nameController.text.trim());
                  _sets.value = await FlashcardManager.getSets();
                  setState(() {
                    _isLoading.value = false;
                  });
                  Navigator.pop(context);
                 SuccessDialog.show(context, 'Đổi tên bộ thẻ thành công');
                } catch (e) {
                  setState(() {
                    _isLoading.value = false;
                  });
                  ErrorDialog.show(context, 'Lỗi đổi tên bộ thẻ');
                }
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

    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar:  AppBar(
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
        leadingWidth: screenWidth,
        leading: Stack(
          children: [
            CustomBackButton_(content: 'Flashcards', color:  Colors.blue,),
            Center(
              child: LogoSmall(),
            ),
          ],
        ),
        actions: [
          StreakCount(),
          SettingButton(),
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
        child: _isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
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
              onPressed: _loadData,
              child: Text('Thử lại'),
            ),
          ],
        ),
      )
          : Column(
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
                    '${_sets.value.length} bộ',
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
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                gridDelegate:  SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: screenWidth / 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.6, // Chiều cao sẽ tỉ lệ với chiều rộng
                ),
                itemCount: _sets.value.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return AddNewSetCard(onCreateSet: _showCreateSetDialog);
                  } else if (index - 1 < _sets.value.length) {
                    return FlashcardSetCard(
                      loadData: _loadData,
                      showRenameSetDialog: _showRenameSetDialog,
                      index: index - 1,
                      sets: _sets,
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ),
        ],
        ),
      ),

      /*floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.add, color: Colors.blue),
        onPressed: _showCreateSetDialog,
      ),*/

    );
  }
}