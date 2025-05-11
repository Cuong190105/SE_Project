import 'package:flutter/material.dart';
import 'package:eng_dictionary/data/models/flashcard_manager.dart';
import 'package:eng_dictionary/features/common/widgets/success_dialog.dart';
import 'package:eng_dictionary/features/common/widgets/error_dialog.dart';

class Synchronize extends StatelessWidget {
  final ValueNotifier<bool> isLoading;
  final ValueNotifier<String?> errorMessage;

  const Synchronize({
    super.key,
    required this.isLoading,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đồng bộ dữ liệu',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text(
          'Đồng bộ flashcard và dữ liệu từ vựng với máy chủ.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        ValueListenableBuilder<bool>(
          valueListenable: isLoading,
          builder: (context, loading, _) {
            return ElevatedButton(
              onPressed: loading ? null : () => _syncData(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Đồng bộ ngay'),
            );
          },
        ),
      ],
    );
  }

  Future<void> _syncData(BuildContext context) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await FlashcardManager.syncToServer();

    if (result['success']) {
      SuccessDialog.show(context, result['message']);
    } else {
      errorMessage.value = result['message'];
      ErrorDialog.show(context, result['message']);
    }
    isLoading.value = false;
  }
}
