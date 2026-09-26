import 'package:flutter/material.dart';

/// A single wallpaper option — either an asset image, a solid color,
/// or a gradient fallback (shown while the asset loads or if missing).
class WallpaperItem {
  final String key;
  final String label;

  /// Asset path, e.g. 'images/wp_aurora.png'
  final String? assetPath;

  /// Solid color (for the 4 solid-color options).
  final Color? solidColor;

  /// Gradient shown as thumbnail preview and as fallback if asset missing.
  final LinearGradient fallbackGradient;

  const WallpaperItem({
    required this.key,
    required this.label,
    required this.fallbackGradient,
    this.assetPath,
    this.solidColor,
  });

  bool get isAsset  => assetPath  != null;
  bool get isSolid  => solidColor != null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Catalogue — 9 wallpapers + 4 solid colors
// ─────────────────────────────────────────────────────────────────────────────
class BuiltInWallpapers {
  BuiltInWallpapers._();

  // ── 9 image wallpapers (PNG files in /images/) ────────────────────────────

  static const crimson = WallpaperItem(
    key: 'wp_crimson',
    label: 'Crimson',
    assetPath: 'images/wp_crimson.png',
    fallbackGradient: LinearGradient(
      colors: [Color(0xFFE53935), Color(0xFFE91E63), Color(0xFF880E4F)],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ),
  );

  static const teal = WallpaperItem(
    key: 'wp_teal',
    label: 'Teal',
    assetPath: 'images/wp_teal.png',
    fallbackGradient: LinearGradient(
      colors: [Color(0xFF2E7D6E), Color(0xFF546E7A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const violet = WallpaperItem(
    key: 'wp_violet',
    label: 'Violet',
    assetPath: 'images/wp_violet.png',
    fallbackGradient: LinearGradient(
      colors: [Color(0xFF4A148C), Color(0xFF7B1FA2), Color(0xFFAD1457)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const nebula = WallpaperItem(
    key: 'wp_nebula',
    label: 'Nebula',
    assetPath: 'images/wp_nebula.png',
    fallbackGradient: LinearGradient(
      colors: [Color(0xFF0A0A2E), Color(0xFF1A0050), Color(0xFF0000FF)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  static const aurora = WallpaperItem(
    key: 'wp_aurora',
    label: 'Aurora',
    assetPath: 'images/wp_aurora.png',
    fallbackGradient: LinearGradient(
      colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4), Color(0xFFA1C4FD)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const cosmos = WallpaperItem(
    key: 'wp_cosmos',
    label: 'Cosmos',
    assetPath: 'images/wp_cosmos.png',
    fallbackGradient: LinearGradient(
      colors: [Color(0xFF3D1A78), Color(0xFF6A1B9A), Color(0xFFAD1457)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const planet = WallpaperItem(
    key: 'wp_planet',
    label: 'Planet',
    assetPath: 'images/wp_planet.png',
    fallbackGradient: LinearGradient(
      colors: [Color(0xFFB8C6DB), Color(0xFFD4DCE8), Color(0xFFF5F7FA)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const silk = WallpaperItem(
    key: 'wp_silk',
    label: 'Silk',
    assetPath: 'images/wp_silk.png',
    fallbackGradient: LinearGradient(
      colors: [Color(0xFFE8ECF0), Color(0xFFF5F7FA)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const waves = WallpaperItem(
    key: 'wp_waves',
    label: 'Waves',
    assetPath: 'images/wp_waves.png',
    fallbackGradient: LinearGradient(
      colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF3949AB)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  /// All 9 wallpapers in 3×3 grid order (left→right, top→bottom).
  static const List<WallpaperItem> assetWallpapers = [
    crimson, teal,   violet,
    nebula,  aurora, cosmos,
    planet,  silk,   waves,
  ];

  // ── 4 solid colors ─────────────────────────────────────────────────────────

  static const solidBlack = WallpaperItem(
    key: 'solid_black',
    label: 'Black',
    solidColor: Color(0xFF000000),
    fallbackGradient: LinearGradient(colors: [Color(0xFF000000), Color(0xFF000000)]),
  );

  static const solidDark = WallpaperItem(
    key: 'solid_dark',
    label: 'Dark',
    solidColor: Color(0xFF141414),
    fallbackGradient: LinearGradient(colors: [Color(0xFF141414), Color(0xFF141414)]),
  );

  static const solidWhite = WallpaperItem(
    key: 'solid_white',
    label: 'White',
    solidColor: Color(0xFFFFFFFF),
    fallbackGradient: LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)]),
  );

  static const solidLightGrey = WallpaperItem(
    key: 'solid_lightgrey',
    label: 'Light Grey',
    solidColor: Color(0xFFE0E0E0),
    fallbackGradient: LinearGradient(colors: [Color(0xFFE0E0E0), Color(0xFFE0E0E0)]),
  );

  static const List<WallpaperItem> solidColors = [
    solidBlack,
    solidDark,
    solidWhite,
    solidLightGrey,
  ];
}
