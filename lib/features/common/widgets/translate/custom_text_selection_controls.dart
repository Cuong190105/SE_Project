import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:eng_dictionary/features/desktop/vocabulary/vocabulary_detail.dart';

class CustomTextSelectionControls extends MaterialTextSelectionControls {
  CustomTextSelectionControls();

  @override
  Widget buildToolbar(
      BuildContext context,
      Rect globalEditableRegion,
      double midpointHeight,
      Offset position,
      List<TextSelectionPoint> endpoints,
      TextSelectionDelegate delegate,
      ValueListenable<ClipboardStatus>? clipboardStatus,
      Offset? lastSecondaryTapDownPosition,
      ) {
    final defaultToolbar = super.buildToolbar(
      context,
      globalEditableRegion,
      midpointHeight,
      position,
      endpoints,
      delegate,
      clipboardStatus,
      lastSecondaryTapDownPosition,
    );

    // Get the selected text from the delegate
    final selectedText = delegate.textEditingValue.text.substring(
      delegate.textEditingValue.selection.start,
      delegate.textEditingValue.selection.end,
    );

    return Container(
      constraints: BoxConstraints(maxHeight: 200, minWidth: 100), // Set a max height
      child: SingleChildScrollView(  // Prevent overflow by wrapping in a scroll view
        child: Column(
          mainAxisSize: MainAxisSize.min,  // Ensure Column doesn't take up the full space
          children: [
            defaultToolbar,
            SizedBox(  // Add height to provide space for HoverEffectButton
              height: 50,  // Height for the button
              child: Material(  // Ensure InkWell works correctly
                color: Colors.transparent,  // Transparent background for Material
                child: InkWell(
                  onTap: () {
                    print("Button pressed");
                    // Handle the tap event
                  },
                  child: Center(  // Use Center to ensure content is properly constrained
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        selectedText.isNotEmpty ? selectedText : 'No text selected',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HoverEffectButton extends StatefulWidget {
  final String word;

  HoverEffectButton({required this.word});

  @override
  _HoverEffectButtonState createState() => _HoverEffectButtonState();
}

class _HoverEffectButtonState extends State<HoverEffectButton> {
  bool _isHovered = false;  // Track hover state

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: Material(
        color: Colors.transparent,  // Transparent material background
        child: InkWell(
          onTap: () {
            Navigator.of(context).maybePop();
            Future.microtask(() {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Vocabulary(word: widget.word), // Navigate to Vocabulary page
                ),
              );
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.word,
              style: TextStyle(
                color: _isHovered ? Colors.grey : Colors.blue, // Change color on hover
              ),
            ),
          ),
        ),
      ),
    );
  }
}
