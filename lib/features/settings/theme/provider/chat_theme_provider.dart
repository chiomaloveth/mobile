import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Chat Theme Model
// ─────────────────────────────────────────────────────────────────────────────

/// Represents the full chat appearance state (global, not per-chat).
class ChatThemeState {
  /// One of: 'default', 'sunset', 'ocean', 'forest', 'lavender', 'midnight',
  ///         'autumn', 'rose'
  final String chatTheme;

  /// Hex string of the custom bubble color, or null for theme default.
  final String? bubbleColorHex;

  /// Wallpaper key — one of:
  /// - 'none'         : no wallpaper (use scaffold bg)
  /// - 'asset_NAME'   : bundled asset wallpaper
  /// - absolute path  : gallery image
  final String wallpaperKey;

  const ChatThemeState({
    this.chatTheme = 'default',
    this.bubbleColorHex,
    this.wallpaperKey = 'none',
  });

  ChatThemeState copyWith({
    String? chatTheme,
    String? bubbleColorHex,
    bool clearBubbleColor = false,
    String? wallpaperKey,
  }) {
    return ChatThemeState(
      chatTheme: chatTheme ?? this.chatTheme,
      bubbleColorHex:
          clearBubbleColor ? null : (bubbleColorHex ?? this.bubbleColorHex),
      wallpaperKey: wallpaperKey ?? this.wallpaperKey,
    );
  }

  /// Returns the sender bubble color for the current theme.
  Color senderBubbleColor(bool isDark) {
    if (bubbleColorHex != null) {
      return Color(int.parse(bubbleColorHex!, radix: 16));
    }
    return _themeColors[chatTheme]?['sender'] ??
        (isDark ? const Color(0xFF1A7F4B) : const Color(0xFFFF8C00));
  }

  /// Returns the receiver bubble color for the current theme.
  Color receiverBubbleColor(bool isDark) {
    return _themeColors[chatTheme]?['receiver'] ??
        (isDark ? const Color(0xFF232323) : Colors.white);
  }

  static const Map<String, Map<String, Color>> _themeColors = {
    'default': {
      'sender':        Color(0xFF1A7F4B),
      'receiver':      Color(0xFF232323),
      'senderGlow':    Color(0xFF00E676), // vivid green
      'receiverGlow':  Color(0xFF69F0AE), // light green
    },
    'sunset': {
      'sender':        Color(0xFFFF6B35),
      'receiver':      Color(0xFFFFB347),
      'senderGlow':    Color(0xFFFF6B35), // orange
      'receiverGlow':  Color(0xFFFFD740), // amber
    },
    'ocean': {
      'sender':        Color(0xFF0077B6),
      'receiver':      Color(0xFF00B4D8),
      'senderGlow':    Color(0xFF00B0FF), // vivid blue
      'receiverGlow':  Color(0xFF00E5FF), // vivid cyan
    },
    'forest': {
      'sender':        Color(0xFF2D6A4F),
      'receiver':      Color(0xFF52B788),
      'senderGlow':    Color(0xFF00C853), // vivid green
      'receiverGlow':  Color(0xFF69F0AE), // light green
    },
    'lavender': {
      'sender':        Color(0xFF7B2FBE),
      'receiver':      Color(0xFFB185DB),
      'senderGlow':    Color(0xFFD500F9), // vivid purple
      'receiverGlow':  Color(0xFFEA80FC), // light purple
    },
    'midnight': {
      'sender':        Color(0xFF1B2A4A),
      'receiver':      Color(0xFF2E4A7A),
      'senderGlow':    Color(0xFF2979FF), // vivid indigo-blue
      'receiverGlow':  Color(0xFF40C4FF), // vivid sky blue
    },
    'autumn': {
      'sender':        Color(0xFFD4522A),
      'receiver':      Color(0xFFE8A87C),
      'senderGlow':    Color(0xFFFF6D00), // vivid orange
      'receiverGlow':  Color(0xFFFFAB40), // amber
    },
    'rose': {
      'sender':        Color(0xFFE91E8C),
      'receiver':      Color(0xFFFF6BB5),
      'senderGlow':    Color(0xFFF50057), // vivid pink-red
      'receiverGlow':  Color(0xFFFF80AB), // light pink
    },
  };

  /// Returns the vivid glow color for the sender bubble.
  Color senderGlowColor() =>
      _themeColors[chatTheme]?['senderGlow'] ?? const Color(0xFFFF8C00);

  /// Returns the vivid glow color for the receiver bubble.
  Color receiverGlowColor() =>
      _themeColors[chatTheme]?['receiverGlow'] ?? const Color(0xFF1A7F4B);
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class ChatThemeNotifier extends AsyncNotifier<ChatThemeState> {
  static const _themeKey      = 'chat_theme_preset';
  static const _bubbleColorKey = 'chat_bubble_color_hex';
  // ✅ Use the SAME key that chat screens read via AppPreferenceHelper.GLOBAL_WALLPAPER
  static const _wallpaperKey  = 'global_wallpaper';

  @override
  Future<ChatThemeState> build() async {
    final prefs = await SharedPreferences.getInstance();
    return ChatThemeState(
      chatTheme: prefs.getString(_themeKey) ?? 'default',
      bubbleColorHex: prefs.getString(_bubbleColorKey),
      wallpaperKey: prefs.getString(_wallpaperKey) ?? 'none',
    );
  }

  Future<void> setChatTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
    state = AsyncData(
      (state.valueOrNull ?? const ChatThemeState()).copyWith(chatTheme: theme),
    );
  }

  Future<void> setBubbleColor(Color? color) async {
    final prefs = await SharedPreferences.getInstance();
    if (color == null) {
      await prefs.remove(_bubbleColorKey);
      state = AsyncData(
        (state.valueOrNull ?? const ChatThemeState())
            .copyWith(clearBubbleColor: true),
      );
    } else {
      final hex = color.toARGB32().toRadixString(16).padLeft(8, '0');
      await prefs.setString(_bubbleColorKey, hex);
      state = AsyncData(
        (state.valueOrNull ?? const ChatThemeState())
            .copyWith(bubbleColorHex: hex),
      );
    }
  }

  Future<void> setWallpaper(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_wallpaperKey, key);
    state = AsyncData(
      (state.valueOrNull ?? const ChatThemeState()).copyWith(wallpaperKey: key),
    );
  }

  Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeKey);
    await prefs.remove(_bubbleColorKey);
    await prefs.remove(_wallpaperKey);
    state = const AsyncData(ChatThemeState());
  }
}

final chatThemeProvider =
    AsyncNotifierProvider<ChatThemeNotifier, ChatThemeState>(
  ChatThemeNotifier.new,
);
