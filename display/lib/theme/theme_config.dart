import 'package:flutter/material.dart';

class ThemeConfig {
  final String id;
  final String name;
  final Color bg;
  final List<Gradient>? bgGradients;
  final Color accent;
  final Color accentBright;
  final Color accentDim;
  final Color marker;
  final Color text;
  final Color textMuted;
  final double ringOpacity;
  final double glowIntensity;

  const ThemeConfig({
    required this.id,
    required this.name,
    required this.bg,
    this.bgGradients,
    required this.accent,
    required this.accentBright,
    required this.accentDim,
    required this.marker,
    required this.text,
    required this.textMuted,
    this.ringOpacity = 1.0,
    this.glowIntensity = 1.0,
  });
}

// Helper to convert hex to Color
Color _hx(String hex) {
  final val = hex.replaceFirst('#', '');
  return Color(int.parse('FF$val', radix: 16));
}

// Helper for RGBA Colors
Color _rgba(int r, int g, int b, double a) {
  return Color.fromRGBO(r, g, b, a);
}

// Convert percentage to flutter alignment (-1.0 to 1.0)
Alignment _align(double xPct, double yPct) {
  return Alignment((xPct - 50) / 50.0, (yPct - 50) / 50.0);
}

final Map<String, ThemeConfig> appThemes = {
  // ---- Dark Themes ----
  'gold': ThemeConfig(
    id: 'gold', name: 'Refined Gold',
    bg: _hx('080808'), bgGradients: null,
    accent: _hx('d4af37'), accentBright: _hx('e8c252'), accentDim: _hx('b8943a'),
    marker: _hx('c8d0d8'), text: _hx('ffffff'), textMuted: _hx('a0a0a0'),
    ringOpacity: 1.0, glowIntensity: 1.0,
  ),
  'sakura': ThemeConfig(
    id: 'sakura', name: 'Sakura Night',
    bg: _hx('16101c'),
    bgGradients: [
      LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [_hx('1a1228'), _hx('16101c'), _hx('201830')],
        stops: [0.0, 0.4, 1.0],
      )
    ],
    accent: _hx('ffb7c5'), accentBright: _hx('ffd4df'), accentDim: _hx('d4909e'),
    marker: _hx('ffc8d4'), text: _hx('fff0f3'), textMuted: _hx('c49aa8'),
    ringOpacity: 1.0, glowIntensity: 1.3,
  ),
  'starlight': ThemeConfig(
    id: 'starlight', name: 'Lunar Silk',
    bg: _hx('0b0a10'),
    bgGradients: [
      RadialGradient(
        center: _align(50, 36), radius: 1.0,
        colors: [_rgba(206, 214, 224, 0.1), _rgba(172, 182, 197, 0.05), Colors.transparent],
        stops: [0.0, 0.38, 0.7],
      ),
      RadialGradient(
        center: _align(30, 82), radius: 0.8,
        colors: [_rgba(194, 202, 216, 0.07), Colors.transparent], stops: [0.0, 0.54],
      ),
      RadialGradient(
        center: _align(70, 24), radius: 0.8,
        colors: [_rgba(214, 158, 168, 0.08), Colors.transparent], stops: [0.0, 0.5],
      ),
    ],
    accent: _hx('cfa685'), accentBright: _hx('e8c2a3'), accentDim: _hx('9f7658'),
    marker: _hx('d5beb2'), text: _hx('f1e5dc'), textMuted: _hx('b9a296'),
    ringOpacity: 1.0, glowIntensity: 1.35,
  ),
  'ember': ThemeConfig(
    id: 'ember', name: 'Ember Glow',
    bg: _hx('110c08'),
    bgGradients: [
      RadialGradient(
        center: _align(50, 100), radius: 1.2,
        colors: [_rgba(255, 100, 30, 0.25), _rgba(180, 60, 10, 0.1), Colors.transparent],
        stops: [0.0, 0.4, 0.7],
      ),
    ],
    accent: _hx('ff9944'), accentBright: _hx('ffbb66'), accentDim: _hx('cc6622'),
    marker: _hx('ffaa55'), text: _hx('fff4e8'), textMuted: _hx('b88860'),
    ringOpacity: 1.0, glowIntensity: 1.4,
  ),
  'rose': ThemeConfig(
    id: 'rose', name: 'Rose Dawn',
    bg: _hx('0a0606'),
    bgGradients: [
      RadialGradient(
        center: _align(50, 75), radius: 1.0,
        colors: [_rgba(120, 50, 55, 0.5), _rgba(80, 35, 40, 0.25), Colors.transparent],
        stops: [0.0, 0.35, 0.65],
      ),
      RadialGradient(
        center: _align(35, 25), radius: 0.8,
        colors: [_rgba(100, 45, 50, 0.2), Colors.transparent], stops: [0.0, 0.45],
      ),
    ],
    accent: _hx('f0a8a0'), accentBright: _hx('ffd4cc'), accentDim: _hx('d08878'),
    marker: _hx('c8d0d8'), text: _hx('ffffff'), textMuted: _hx('a0a0a0'),
    ringOpacity: 1.0, glowIntensity: 1.0,
  ),
  'emerald': ThemeConfig(
    id: 'emerald', name: 'Emerald Night',
    bg: _hx('080a08'),
    bgGradients: [
      RadialGradient(
        center: _align(50, 30), radius: 1.0,
        colors: [_rgba(30, 60, 35, 0.3), Colors.transparent], stops: [0.0, 0.6],
      ),
    ],
    accent: _hx('88d498'), accentBright: _hx('b0f0c0'), accentDim: _hx('60a070'),
    marker: _hx('a0e0b0'), text: _hx('ffffff'), textMuted: _hx('90b898'),
    ringOpacity: 1.0, glowIntensity: 1.5,
  ),
  'ocean': ThemeConfig(
    id: 'ocean', name: 'Ocean Depth',
    bg: _hx('080a0a'),
    bgGradients: [
      RadialGradient(
        center: _align(50, 60), radius: 1.0,
        colors: [_rgba(25, 50, 50, 0.4), Colors.transparent], stops: [0.0, 0.6],
      ),
    ],
    accent: _hx('7cb8b8'), accentBright: _hx('a8d8d8'), accentDim: _hx('5a8a8a'),
    marker: _hx('c8d0d8'), text: _hx('ffffff'), textMuted: _hx('a0a0a0'),
    ringOpacity: 1.0, glowIntensity: 1.0,
  ),
  'twilight': ThemeConfig(
    id: 'twilight', name: 'Twilight Sapphire',
    bg: _hx('080c14'),
    bgGradients: [
      RadialGradient(
        center: _align(50, 0), radius: 1.2,
        colors: [_rgba(30, 50, 80, 0.4), Colors.transparent], stops: [0.0, 0.6],
      ),
    ],
    accent: _hx('a8c5d9'), accentBright: _hx('d4e5ef'), accentDim: _hx('6a8fa8'),
    marker: _hx('c8d0d8'), text: _hx('ffffff'), textMuted: _hx('a0a0a0'),
    ringOpacity: 1.0, glowIntensity: 1.0,
  ),
  'coral': ThemeConfig(
    id: 'coral', name: 'Coral Reef',
    bg: _hx('0a1018'),
    bgGradients: [
      RadialGradient(
        center: _align(50, 40), radius: 1.0,
        colors: [_rgba(20, 40, 60, 0.5), Colors.transparent], stops: [0.0, 0.6],
      ),
      RadialGradient(
        center: _align(30, 70), radius: 0.9,
        colors: [_rgba(15, 35, 55, 0.4), Colors.transparent], stops: [0.0, 0.5],
      ),
    ],
    accent: _hx('e8a060'), accentBright: _hx('f8c080'), accentDim: _hx('c88848'),
    marker: _hx('c8d0d8'), text: _hx('ffffff'), textMuted: _hx('a0a0a0'),
    ringOpacity: 1.0, glowIntensity: 1.0,
  ),
  'manuscript': ThemeConfig(
    id: 'manuscript', name: 'Medina Ink',
    bg: _hx('1a0810'),
    bgGradients: [
      RadialGradient(
        center: _align(50, 40), radius: 1.0,
        colors: [_rgba(80, 20, 35, 0.5), Colors.transparent], stops: [0.0, 0.6],
      ),
      RadialGradient(
        center: _align(70, 70), radius: 0.9,
        colors: [_rgba(60, 15, 28, 0.4), Colors.transparent], stops: [0.0, 0.5],
      ),
    ],
    accent: _hx('f0a8b8'), accentBright: _hx('ffd0dc'), accentDim: _hx('d08898'),
    marker: _hx('c8d0d8'), text: _hx('f5e8d0'), textMuted: _hx('c0a888'),
    ringOpacity: 1.0, glowIntensity: 1.0,
  ),
  'onyx_neon': ThemeConfig(
    id: 'onyx_neon', name: 'Onyx Neon',
    bg: _hx('000000'),
    bgGradients: [
      RadialGradient(
        center: _align(50, 50), radius: 1.0,
        colors: [_rgba(0, 255, 255, 0.05), Colors.transparent], stops: [0.0, 0.7],
      ),
    ],
    accent: _hx('00ffff'), accentBright: _hx('aaffff'), accentDim: _hx('00cccc'),
    marker: _hx('ffffff'), text: _hx('e0ffff'), textMuted: _hx('00aaaa'),
    ringOpacity: 1.0, glowIntensity: 2.0,
  ),
  'amethyst_glow': ThemeConfig(
    id: 'amethyst_glow', name: 'Amethyst Night',
    bg: _hx('0b061a'),
    bgGradients: [
      LinearGradient( // approx for 135deg
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [_hx('0b061a'), _hx('1a0b35')], stops: [0.0, 1.0],
      )
    ],
    accent: _hx('d946ef'), accentBright: _hx('f5d0fe'), accentDim: _hx('a21caf'),
    marker: _hx('fbcfe8'), text: _hx('fae8ff'), textMuted: _hx('c084fc'),
    ringOpacity: 1.0, glowIntensity: 1.6,
  ),

  // ---- Light Themes ---- //
  'mint_forest': ThemeConfig(
    id: 'mint_forest', name: 'Mint Leaf',
    bg: _hx('f5fdf9'),
    accent: _hx('2d5a27'), accentBright: _hx('4a8a3f'), accentDim: _hx('1a3d16'),
    marker: _hx('d1f2e1'), text: _hx('122610'), textMuted: _hx('4a6b47'),
    ringOpacity: 1.8, glowIntensity: 0.9,
  ),
  'royal_indigo': ThemeConfig(
    id: 'royal_indigo', name: 'Royal Lavender',
    bg: _hx('fcfaff'),
    accent: _hx('4c1d95'), accentBright: _hx('7c3aed'), accentDim: _hx('2e1065'),
    marker: _hx('ede9fe'), text: _hx('1e1b4b'), textMuted: _hx('4338ca'),
    ringOpacity: 1.7, glowIntensity: 1.1,
  ),
  'desert_rose': ThemeConfig(
    id: 'desert_rose', name: 'Desert Sand',
    bg: _hx('fffbf5'),
    accent: _hx('c05621'), accentBright: _hx('ed8936'), accentDim: _hx('7b341e'),
    marker: _hx('fef3c7'), text: _hx('431908'), textMuted: _hx('8b5033'),
    ringOpacity: 1.6, glowIntensity: 1.0,
  ),
  'cream_sepia': ThemeConfig(
    id: 'cream_sepia', name: 'Cream Parchment',
    bg: _hx('fbf8f1'),
    accent: _hx('800000'), accentBright: _hx('a52a2a'), accentDim: _hx('4d0000'),
    marker: _hx('f3e5ab'), text: _hx('2b1d0e'), textMuted: _hx('5e432c'),
    ringOpacity: 1.5, glowIntensity: 0.8,
  ),
  'light_cedar': ThemeConfig(
    id: 'light_cedar', name: 'Cedar Forest',
    bg: _hx('ffffff'),
    accent: _hx('0d6b38'), accentBright: _hx('189b53'), accentDim: _hx('084b26'),
    marker: _hx('c4eada'), text: _hx('062612'), textMuted: _hx('3d7a5b'),
    ringOpacity: 2.0, glowIntensity: 1.0,
  ),
  'light_persian': ThemeConfig(
    id: 'light_persian', name: 'Persian Tile',
    bg: _hx('ffffff'),
    accent: _hx('1e3a8a'), accentBright: _hx('3b82f6'), accentDim: _hx('1e40af'),
    marker: _hx('dbeafe'), text: _hx('0b192c'), textMuted: _hx('475569'),
    ringOpacity: 2.0, glowIntensity: 1.0,
  ),
  'gold_light': ThemeConfig(
    id: 'gold_light', name: 'Ottoman Crimson',
    bg: _hx('2a1010'),
    bgGradients: [
      RadialGradient(
        center: _align(50, 40), radius: 1.0,
        colors: [_rgba(160, 50, 50, 0.7), _rgba(120, 30, 30, 0.4), Colors.transparent], stops: [0.0, 0.5, 0.8],
      ),
      RadialGradient(
        center: _align(30, 70), radius: 0.9,
        colors: [_rgba(140, 40, 40, 0.5), Colors.transparent], stops: [0.0, 0.6],
      ),
    ],
    accent: _hx('f0c878'), accentBright: _hx('ffe098'), accentDim: _hx('d0a858'),
    marker: _hx('f0e8d0'), text: _hx('fff8e8'), textMuted: _hx('d0c090'),
    ringOpacity: 2.0, glowIntensity: 1.0,
  ),
  'rose_light': ThemeConfig(
    id: 'rose_light', name: 'Fajr Blush',
    bg: _hx('281418'),
    bgGradients: [
      RadialGradient(
        center: _align(50, 30), radius: 1.0,
        colors: [_rgba(180, 80, 100, 0.6), _rgba(140, 60, 80, 0.35), Colors.transparent], stops: [0.0, 0.5, 0.8],
      ),
      RadialGradient(
        center: _align(30, 70), radius: 0.9,
        colors: [_rgba(160, 70, 90, 0.5), Colors.transparent], stops: [0.0, 0.6],
      ),
    ],
    accent: _hx('f8d898'), accentBright: _hx('ffe8b0'), accentDim: _hx('d8b878'),
    marker: _hx('f8e8c8'), text: _hx('fff8e0'), textMuted: _hx('d0b888'),
    ringOpacity: 2.0, glowIntensity: 1.0,
  ),
  'emerald_light': ThemeConfig(
    id: 'emerald_light', name: 'Cedar Night',
    bg: _hx('101c14'),
    bgGradients: [
      RadialGradient(
        center: _align(50, 40), radius: 1.0,
        colors: [_rgba(40, 90, 60, 0.7), _rgba(25, 60, 40, 0.4), Colors.transparent], stops: [0.0, 0.5, 0.8],
      ),
    ],
    accent: _hx('d8e8e0'), accentBright: _hx('e8f8f0'), accentDim: _hx('b8c8c0'),
    marker: _hx('d0e8e0'), text: _hx('f0fff8'), textMuted: _hx('a0b8b0'),
    ringOpacity: 2.0, glowIntensity: 1.0,
  ),
  'ocean_light': ThemeConfig(
    id: 'ocean_light', name: 'Turquoise Coral',
    bg: _hx('102428'),
    bgGradients: [
      RadialGradient(
        center: _align(60, 40), radius: 1.0,
        colors: [_rgba(50, 140, 160, 0.6), _rgba(30, 100, 120, 0.35), Colors.transparent], stops: [0.0, 0.5, 0.8],
      ),
    ],
    accent: _hx('f0a890'), accentBright: _hx('ffc0a8'), accentDim: _hx('d08870'),
    marker: _hx('f0e0d8'), text: _hx('fff4ec'), textMuted: _hx('d0a898'),
    ringOpacity: 2.0, glowIntensity: 1.0,
  ),
  'twilight_light': ThemeConfig(
    id: 'twilight_light', name: 'Iznik Cobalt',
    bg: _hx('101830'),
    bgGradients: [
      RadialGradient(
        center: _align(50, 30), radius: 1.0,
        colors: [_rgba(60, 90, 180, 0.6), _rgba(40, 60, 140, 0.35), Colors.transparent], stops: [0.0, 0.5, 0.8],
      ),
    ],
    accent: _hx('f0c878'), accentBright: _hx('ffe098'), accentDim: _hx('d0a858'),
    marker: _hx('f0e8d0'), text: _hx('fffaec'), textMuted: _hx('d0c090'),
    ringOpacity: 2.0, glowIntensity: 1.0,
  ),
  'manuscript_light': ThemeConfig(
    id: 'manuscript_light', name: 'Plum Manuscript',
    bg: _hx('281020'),
    bgGradients: [
      RadialGradient(
        center: _align(50, 40), radius: 1.0,
        colors: [_rgba(140, 60, 100, 0.6), _rgba(100, 40, 70, 0.35), Colors.transparent], stops: [0.0, 0.5, 0.8],
      ),
      RadialGradient(
        center: _align(70, 70), radius: 0.9,
        colors: [_rgba(120, 50, 85, 0.5), Colors.transparent], stops: [0.0, 0.6],
      ),
    ],
    accent: _hx('f8d8a0'), accentBright: _hx('ffe8b8'), accentDim: _hx('d8b880'),
    marker: _hx('f8e8c8'), text: _hx('fff8e0'), textMuted: _hx('d0c098'),
    ringOpacity: 2.0, glowIntensity: 1.0,
  ),
};
