import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TestControls extends StatelessWidget {
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onTestSilence;
  final VoidCallback onTestProhibited;
  final VoidCallback onExit;
  final Function(Duration) onTimeShift;
  final VoidCallback onTimeReset;

  const TestControls({
    super.key,
    required this.onPrevious,
    required this.onNext,
    required this.onTestSilence,
    required this.onTestProhibited,
    required this.onExit,
    required this.onTimeShift,
    required this.onTimeReset,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKeyEvent: (event) {
        if (event is! KeyDownEvent) return;

        final isCtrl = HardwareKeyboard.instance.isControlPressed;
        final isShift = HardwareKeyboard.instance.isShiftPressed;

        // Reset/Exit Logic
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          onTimeReset();
          onExit();
          return;
        }

        // --- Mode Toggles (Ctrl + Key) ---
        if (isCtrl && event.logicalKey == LogicalKeyboardKey.keyS) {
          onTestSilence();
          return;
        }
        if (isCtrl && event.logicalKey == LogicalKeyboardKey.keyP) {
          onTestProhibited();
          return;
        }

        // --- Time Simulation (Ctrl + Arrows = Hours, Shift + Arrows = Minutes, Shift + Horiz = Days) ---
        if (isCtrl) {
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            onTimeShift(const Duration(hours: 1));
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            onTimeShift(const Duration(hours: -1));
          }
        } else if (isShift) {
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            onTimeShift(const Duration(minutes: 1));
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            onTimeShift(const Duration(minutes: -1));
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            onTimeShift(const Duration(days: 1));
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            onTimeShift(const Duration(days: -1));
          }
        } 
        // --- Standard Navigation (Arrows without modifiers) ---
        else {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            onPrevious();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            onNext();
          }
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}
