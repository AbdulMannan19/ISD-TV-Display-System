import 'package:flutter/material.dart';

/// Test overlay with navigation arrows and test buttons - REMOVE IN PRODUCTION
class TestControls extends StatelessWidget {
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onTestSilence;
  final VoidCallback onTestProhibited;

  const TestControls({
    super.key,
    required this.onPrevious,
    required this.onNext,
    required this.onTestSilence,
    required this.onTestProhibited,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Left arrow
        Positioned(
          left: 20,
          top: 0,
          bottom: 0,
          child: Center(
            child: _buildArrowButton(
              icon: Icons.arrow_back_ios,
              onTap: onPrevious,
            ),
          ),
        ),
        
        // Right arrow
        Positioned(
          right: 20,
          top: 0,
          bottom: 0,
          child: Center(
            child: _buildArrowButton(
              icon: Icons.arrow_forward_ios,
              onTap: onNext,
            ),
          ),
        ),

        // Test buttons panel (top right)
        Positioned(
          top: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildTestButton(
                label: 'Test Silence (30s)',
                icon: Icons.volume_off,
                onTap: onTestSilence,
              ),
              const SizedBox(height: 8),
              _buildTestButton(
                label: 'Test Prohibited (30s)',
                icon: Icons.block,
                onTap: onTestProhibited,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArrowButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildTestButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
