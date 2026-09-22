import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// Central theme definitions for QikTalk.
///
/// Dark mode is the primary design; light mode uses warm off-white tones
/// with the orange accent (#FF8C00 — same as the Wallet FAB) as the
/// secondary/highlight colour throughout.
class AppTheme {
  AppTheme._();

  // ── Dark Theme ─────────────────────────────────────────────────────────────
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(AppColors.primaryBackgroundColor),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFC65800),
        secondary: Color(0xFFFF9800),
        surface: Color(AppColors.primaryColor),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(AppColors.gradientColorsOne),
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      cardColor: const Color(AppColors.primaryColor),
      dividerColor: Colors.white12,
      iconTheme: const IconThemeData(color: Colors.white),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Color(0xFFA3A3A3)),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF151515),
        hintStyle: const TextStyle(color: Color(0xFF9D9D9D)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ── Light Theme ────────────────────────────────────────────────────────────
  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightNavBar, // Use same as CustomBottomNav
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightAccent,
        secondary: AppColors.lightAccent,
        surface: AppColors.lightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(AppColors.gradientColorsOne),
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
        ),
      ),
      cardColor: AppColors.lightCardBg,
      dividerColor: AppColors.lightDivider,
      iconTheme: const IconThemeData(color: AppColors.lightIconColor),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
        bodyMedium: TextStyle(color: AppColors.lightTextPrimary),
        bodySmall: TextStyle(color: AppColors.lightTextSecondary),
        titleLarge: TextStyle(color: AppColors.lightTextPrimary),
        titleMedium: TextStyle(color: AppColors.lightTextPrimary),
        titleSmall: TextStyle(color: AppColors.lightTextPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightInputBg,
        hintStyle: const TextStyle(color: AppColors.lightTextHint),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ── Core Helpers ───────────────────────────────────────────────────────────

  /// Scaffold / page background.
  static Color scaffoldBg(bool isDark) =>
      isDark ? const Color(AppColors.primaryBackgroundColor) : AppColors.lightNavBar;

  /// Card / container background.
  static Color cardBg(bool isDark) =>
      isDark ? const Color(0xFF1E1E1E) : AppColors.lightCardBg;

  /// Slightly elevated card (e.g. inner cards on a card).
  static Color cardBgAlt(bool isDark) =>
      isDark ? const Color(0xFF2A2A2A) : AppColors.lightSurfaceAlt;

  /// Primary body text.
  static Color textPrimary(bool isDark) =>
      isDark ? Colors.white : AppColors.lightTextPrimary;

  /// Secondary / subtitle text.
  static Color textSecondary(bool isDark) =>
      isDark ? const Color(0xFFA3A3A3) : AppColors.lightTextSecondary;

  /// Hint / placeholder text.
  static Color textHint(bool isDark) =>
      isDark ? const Color(0xFF9D9D9D) : AppColors.lightTextHint;

  /// Divider / separator line.
  static Color divider(bool isDark) =>
      isDark ? Colors.black : AppColors.lightDivider;

  /// Subtle divider (inside cards).
  static Color dividerSubtle(bool isDark) =>
      isDark ? const Color(0xFF2C2C2E) : AppColors.lightDivider;

  /// Icon background container.
  static Color iconBg(bool isDark) =>
      isDark ? const Color(0xFF262626) : AppColors.lightIconBg;

  /// Icon colour on a page/card background.
  static Color iconColor(bool isDark) =>
      isDark ? Colors.white : AppColors.lightIconColor;

  /// Icon colour for subtle/secondary icons.
  static Color iconColorSubtle(bool isDark) =>
      isDark ? const Color(0xFFA3A3A3) : const Color(0xFF6A6A6A);

  /// Input field fill.
  static Color inputFill(bool isDark) =>
      isDark ? const Color(0xFF151515) : AppColors.lightInputBg;

  /// Input border.
  static Color inputBorder(bool isDark) =>
      isDark ? Colors.transparent : AppColors.lightInputBorder;

  /// Bottom nav bar background.
  static Color navBarBg(bool isDark) =>
      isDark ? const Color(AppColors.primaryBackgroundColor) : AppColors.lightNavBar;

  /// The orange accent — same as Wallet FAB, used for active states,
  /// sender bubbles, highlights.
  static Color accent(bool isDark) => AppColors.lightAccent; // same in both modes

  /// Sender chat bubble background.
  static Color senderBubble(bool isDark) =>
      isDark ? const Color(0xFF1A7F4B) : AppColors.lightSenderBubble;

  /// Receiver chat bubble background.
  static Color receiverBubble(bool isDark) =>
      isDark ? const Color(0xFF1E1E1E) : AppColors.lightReceiverBubble;

  /// Sender bubble text colour.
  static Color senderBubbleText(bool isDark) => Colors.white;

  /// Receiver bubble text colour.
  static Color receiverBubbleText(bool isDark) =>
      isDark ? Colors.white : AppColors.lightTextPrimary;

  /// Border / outline colour.
  static Color border(bool isDark) =>
      isDark ? const Color(0xFF2C2C2E) : AppColors.lightBorder;

  /// Switch inactive track.
  static Color switchInactiveTrack(bool isDark) =>
      isDark ? Colors.white10 : Colors.black12;

  /// Popup / dropdown menu background.
  static Color popupBg(bool isDark) =>
      isDark ? const Color(0xFF1E1E1E) : AppColors.lightNavBar;

  /// Popup menu text colour.
  static Color popupText(bool isDark) =>
      isDark ? Colors.white : AppColors.lightTextPrimary;
      
  /// Success/active green color (e.g., for switches, success messages, active states).
  /// Uses darker green in light mode for better visibility.
  static Color successGreen(bool isDark) =>
      isDark ? AppColors.darkGreen : AppColors.lightGreen;
}
