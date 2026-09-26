import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

// ── Text Size ──────────────────────────────────────────────────────────────
// Index: 0 = Small, 1 = Medium (default), 2 = Large, 3 = Extra Large
final textSizeProvider = NotifierProvider<TextSizeNotifier, int>(
  TextSizeNotifier.new,
);

class TextSizeNotifier extends Notifier<int> {
  static const String _key = 'text_size_index';

  @override
  int build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    // Read as int; fall back to legacy double storage for existing users
    final raw = prefs.get(_key);
    final stored = raw != null ? (raw as num).toInt() : null;
    if (stored != null) return stored.clamp(0, 3);
    // Legacy: was stored as double (0.0, 0.667, 1.333, 2.0)
    final legacy = raw is double ? raw : null;
    if (legacy != null) {
      if (legacy <= 0.1) return 0;
      if (legacy <= 0.8) return 1;
      if (legacy <= 1.5) return 2;
      return 3;
    }
    return 1; // default: Medium
  }

  Future<void> setSize(int index) async {
    final clamped = index.clamp(0, 3);
    state = clamped;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_key, clamped);
  }

  /// Maps index 0–3 to a TextScaler linear factor.
  /// Small=0.85, Medium=1.0, Large=1.18, Extra Large=1.38
  static double toScaleFactor(int index) {
    switch (index) {
      case 0:
        return 0.85; // Small
      case 1:
        return 1.0; // Medium
      case 2:
        return 1.18; // Large
      case 3:
        return 1.38; // Extra Large
      default:
        return 1.0;
    }
  }
}

class ThemeNotifier extends Notifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';

  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final themeString = prefs.getString(_themeKey);

    ThemeMode initialMode;
    if (themeString == 'light') {
      initialMode = ThemeMode.light;
    } else if (themeString == 'dark') {
      initialMode = ThemeMode.dark;
    } else {
      initialMode = ThemeMode.system;
    }

    _updateSystemOverlayStyle(initialMode);

    return initialMode;
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = ref.read(sharedPreferencesProvider);
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
      default:
        value = 'system';
        break;
    }
    await prefs.setString(_themeKey, value);

    _updateSystemOverlayStyle(mode);
  }

  void _updateSystemOverlayStyle(ThemeMode mode) {
    bool isDark;

    if (mode == ThemeMode.system) {
      final brightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      isDark = brightness == Brightness.dark;
    } else {
      isDark = mode == ThemeMode.dark;
    }

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDark
            ? const Color(0xFF121212)
            : Colors.white,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }
}
