import 'package:flutter/material.dart';
import '../services/shared_data.dart';
import 'content_screen.dart';

class VerseScreen extends StatelessWidget {
  const VerseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentScreen(
      title: 'VERSE OF THE DAY',
      fetchContent: () async => SharedData.instance.currentVerse,
      contentBgColor: const Color(0xFFF0F4FF),   // light periwinkle
      contentTextColor: const Color(0xFF0D2F6E), // royal navy blue
    );
  }
}
