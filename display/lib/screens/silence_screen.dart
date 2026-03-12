import 'package:flutter/material.dart';

class SilenceScreen extends StatelessWidget {
  const SilenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'SILENCE PLEASE',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 72,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 80),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIcon(Icons.phone_disabled, 80),
                    const SizedBox(width: 100),
                    _buildIcon(Icons.voice_over_off, 80),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            right: 40,
            child: _buildMosqueLogo(),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData icon, double size) {
    return Icon(
      icon,
      size: size,
      color: const Color(0xFF4B5563),
    );
  }

  Widget _buildMosqueLogo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF374151), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.mosque,
        size: 32,
        color: Color(0xFF6B7280),
      ),
    );
  }
}
