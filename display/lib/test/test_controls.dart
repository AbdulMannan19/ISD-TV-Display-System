import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Test overlay with keyboard shortcuts - REMOVE IN PRODUCTION
/// Arrow keys: navigate screens
/// Ctrl+S: toggle silence screen
/// Ctrl+P: toggle prohibited screen
/// Esc: exit silence/prohibited and return to normal
class TestControls extends StatelessWidget {
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onTestSilence;
  final VoidCallback onTestProhibited;
  final VoidCallback onExit;

  const TestControls({
    super.key,
    required this.onPrevious,
    required this.onNext,
    required this.onTestSilence,
    required this.onTestProhibited,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKeyEvent: (event) {
        if (event is! KeyDownEvent) return;

        final isCtrl = HardwareKeyboard.instance.isControlPressed;

        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          onPrevious();
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          onNext();
        } else if (isCtrl && event.logicalKey == LogicalKeyboardKey.keyS) {
          onTestSilence();
        } else if (isCtrl && event.logicalKey == LogicalKeyboardKey.keyP) {
          onTestProhibited();
        } else if (event.logicalKey == LogicalKeyboardKey.escape) {
          onExit();
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}
