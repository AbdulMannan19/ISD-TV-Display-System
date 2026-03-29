import 'package:flutter/material.dart';
import '../services/shared_data.dart';
import 'content_screen.dart';

class DuaScreen extends StatelessWidget {
  const DuaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentScreen(
      title: 'DUA OF THE DAY',
      fetchContent: () async => SharedData.instance.currentDua,
      contentBgColor: const Color(0xFFFFF1F1),   // light rose
      contentTextColor: const Color(0xFF8B1A1A), // deep crimson
    );
  }
}
