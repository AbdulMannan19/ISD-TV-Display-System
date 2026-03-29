import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class SlidesScreen extends StatelessWidget {
  final Map<String, dynamic> slide;

  const SlidesScreen({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    final imageUrl = slide['image_url'] as String;
    final theme = ThemeService().current;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: theme.bg,
            child: Center(
              child: CircularProgressIndicator(color: theme.accent),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return ThemeService().buildBackground(
            child: Center(
              child: Icon(
                Icons.broken_image,
                size: 64,
                color: theme.textMuted.withOpacity(0.5),
              ),
            ),
          );
        },
      ),
    );
  }
}
