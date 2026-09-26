import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/features/settings/theme/screens/chat_themes_screen.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

import '../../../../utilities/components/buttons/custom_back_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens (match Figma exactly)
// ─────────────────────────────────────────────────────────────────────────────
const _kDarkScaffold    = Color(0xFF141414);
const _kDarkCard        = Color(0xFF1E1A17);
const _kDarkIconBox     = Color(0xFF2A2522);
const _kDarkLabel       = Color(0xFF6B6B6B);
const _kDarkSubtitle    = Color(0xFF8A8A8A);
const _kDarkDivider     = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
const _kDarkBorder      = Color(0x12FFFFFF); // rgba(255,255,255,0.07)
const _kGreen           = Color(0xFF2ECC71);
const _kOrange          = Color(0xFFFF8C00);
const _kSelectedRowDark = Color(0xFF5A3A08);

const _kLightScaffold    = Color(0xFFFAF5F0);
const _kLightCard        = Color(0xFFF2EDE8);
const _kLightIconBox     = Color(0xFFDDD3C5);
const _kLightLabel       = Color(0xFF4A4A4A);
const _kLightSubtitle    = Color(0xFF6B6B6B);
const _kLightDivider     = Color(0xFFD9CFC4);
const _kLightBorder      = Color(0xFFCFC4B5);
const _kLightText        = Color(0xFF1A1008);
const _kSelectedRowLight = Color(0xFFFFF0DC);

class ThemeScreen extends ConsumerStatefulWidget {
  const ThemeScreen({super.key});

  @override
  ConsumerState<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends ConsumerState<ThemeScreen> {
  String _selectedChatWallpaper = 'default';
  // Default: Medium (index 1) — reflects until backend/prefs load
  int _textSizeIndex = 1;

  @override
  void initState() {
    super.initState();
    // Immediately reflect whatever is already persisted locally
    Future.microtask(() {
      if (!mounted) return;
      final stored = ref.read(textSizeProvider);
      setState(() => _textSizeIndex = stored);
      _loadThemeFromBackend();
    });
  }

  Future<void> _loadThemeFromBackend() async {
    try {
      final sv = SaveValues();
      final token = await sv.getString(AppPreferenceHelper.AUTH_TOKEN);
      final res = await http.get(
        Uri.parse('${ApiStrings.baseUri}user/user-info'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );
      if (res.statusCode == 200) {
        final settings = jsonDecode(res.body)['data']?['settings'];
        if (settings != null && mounted) {
          final tm = settings['themeMode'] as String?;
          if (tm != null) {
            final n = ref.read(themeProvider.notifier);
            if (tm == 'light') {
              n.setTheme(ThemeMode.light);
            } else if (tm == 'dark') {
              n.setTheme(ThemeMode.dark);
            } else {
              n.setTheme(ThemeMode.system);
            }
          }
          final wp = settings['chatWallpaper'] as String?;
          if (wp != null) setState(() => _selectedChatWallpaper = wp);
          // Backend sends textSize as a double index (0–3)
          final ts = settings['textSize'];
          if (ts != null) {
            final idx = (ts is double ? ts.round() : (ts as int)).clamp(0, 3);
            ref.read(textSizeProvider.notifier).setSize(idx);
            if (mounted) setState(() => _textSizeIndex = idx);
          }
        }
      }
    } catch (_) {}
  }

  void _handleThemeSelection(String value) {
    final n = ref.read(themeProvider.notifier);
    if (value == 'light') {
      n.setTheme(ThemeMode.light);
    } else if (value == 'dark') {
      n.setTheme(ThemeMode.dark);
    } else {
      n.setTheme(ThemeMode.system);
    }
    _syncTheme(value);
  }

  Future<void> _syncTheme(String v) async {
    try {
      final sv = SaveValues();
      final token = await sv.getString(AppPreferenceHelper.AUTH_TOKEN);
      await http.put(
        Uri.parse('${ApiStrings.baseUri}user/settings/appearance'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({'themeMode': v, 'chatWallpaper': _selectedChatWallpaper, 'textSize': _textSizeIndex.toDouble()}),
      );
    } catch (_) {}
  }

  void _handleWallpaperSelection(String value) {
    setState(() => _selectedChatWallpaper = value);
    _syncWallpaper(value);
  }

  Future<void> _syncWallpaper(String wp) async {
    try {
      final sv = SaveValues();
      final token = await sv.getString(AppPreferenceHelper.AUTH_TOKEN);
      await http.put(
        Uri.parse('${ApiStrings.baseUri}user/settings/appearance'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({'chatWallpaper': wp}),
      );
    } catch (_) {}
  }

  void _handleTextSizeSelection(int index) {
    setState(() => _textSizeIndex = index);
    // Pass the index directly — no formula needed
    ref.read(textSizeProvider.notifier).setSize(index);
    _syncTextSize(index);
  }

  Future<void> _syncTextSize(int index) async {
    try {
      final sv = SaveValues();
      final token = await sv.getString(AppPreferenceHelper.AUTH_TOKEN);
      await http.put(
        Uri.parse('${ApiStrings.baseUri}user/settings/appearance'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({'textSize': index.toDouble()}),
      );
    } catch (_) {}
  }

  String _themeString(ThemeMode m) {
    if (m == ThemeMode.light) return 'light';
    if (m == ThemeMode.dark) return 'dark';
    return 'system default';
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(themeProvider);
    final sysBrightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = mode == ThemeMode.dark ||
        (mode == ThemeMode.system && sysBrightness == Brightness.dark);
    final String currentTheme = _themeString(mode);

    final scaffoldBg  = isDark ? _kDarkScaffold  : _kLightScaffold;
    final cardBg      = isDark ? _kDarkCard       : _kLightCard;
    final labelColor  = isDark ? _kDarkLabel      : _kLightLabel;
    final primaryText = isDark ? Colors.white     : _kLightText;
    final divider     = isDark ? _kDarkDivider    : _kLightDivider;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: scaffoldBg,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: scaffoldBg,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(AppColors.gradientColorsTwo), Color(AppColors.gradientColorsOne)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: CustomBackButton(buildContext: context),
              title: Text(
                'Themes & Appearance',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── CHAT CUSTOMIZATION ────────────────────────────────────────
              _Label('CHAT CUSTOMIZATION', labelColor),
              const SizedBox(height: 8),
              _Card(
                isDark: isDark,
                cardBg: cardBg,
                child: _ChatThemesRow(isDark: isDark, primaryText: primaryText),
              ),

              const SizedBox(height: 24),

              // ── THEME ─────────────────────────────────────────────────────
              _Label('THEME', labelColor),
              const SizedBox(height: 8),
              _Card(
                isDark: isDark,
                cardBg: cardBg,
                child: Column(children: [
                  _ThemeRow(
                    isDark: isDark, primaryText: primaryText, divider: divider,
                    label: 'Dark', isSelected: currentTheme == 'dark',
                    circleColor: const Color(0xFF1A2A3A),
                    onTap: () => _handleThemeSelection('dark'),
                    showDivider: true,
                  ),
                  _ThemeRow(
                    isDark: isDark, primaryText: primaryText, divider: divider,
                    label: 'Light', isSelected: currentTheme == 'light',
                    circleColor: Colors.white,
                    onTap: () => _handleThemeSelection('light'),
                    showDivider: false,
                  ),
                ]),
              ),

              const SizedBox(height: 24),

              // ── TEXT SIZE ─────────────────────────────────────────────────
              _Label('TEXT SIZE', labelColor),
              const SizedBox(height: 8),
              _Card(
                isDark: isDark,
                cardBg: cardBg,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(children: [
                    _TextSizeRow(isDark: isDark, primaryText: primaryText,
                      label: 'Small', fontSize: 13, index: 0, selected: _textSizeIndex,
                      onTap: () => _handleTextSizeSelection(0)),
                    _TextSizeRow(isDark: isDark, primaryText: primaryText,
                      label: 'Medium', fontSize: 15.5, index: 1, selected: _textSizeIndex,
                      onTap: () => _handleTextSizeSelection(1)),
                    _TextSizeRow(isDark: isDark, primaryText: primaryText,
                      label: 'Large', fontSize: 18, index: 2, selected: _textSizeIndex,
                      onTap: () => _handleTextSizeSelection(2)),
                    _TextSizeRow(isDark: isDark, primaryText: primaryText,
                      label: 'Extra Large', fontSize: 21, index: 3, selected: _textSizeIndex,
                      onTap: () => _handleTextSizeSelection(3)),
                  ]),
                ),
              ),

              const SizedBox(height: 24),

              // ── CHAT WALLPAPER ────────────────────────────────────────────
              _Label('CHAT WALLPAPER', labelColor),
              const SizedBox(height: 8),
              _WallpaperRow(
                isDark: isDark,
                cardBg: cardBg,
                selected: _selectedChatWallpaper,
                onSelect: _handleWallpaperSelection,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  final Color color;
  const _Label(this.text, this.color);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 2),
    child: Text(text,
      style: GoogleFonts.poppins(
        fontSize: 11, fontWeight: FontWeight.w600,
        color: color, letterSpacing: 1.1,
      ),
    ),
  );
}

class _Card extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final Widget child;
  const _Card({required this.isDark, required this.cardBg, required this.child});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? _kDarkBorder : _kLightBorder,
          width: 1,
        ),
      ),
      child: child,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat Themes row
// ─────────────────────────────────────────────────────────────────────────────
class _ChatThemesRow extends StatelessWidget {
  final bool isDark;
  final Color primaryText;
  const _ChatThemesRow({required this.isDark, required this.primaryText});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatThemesScreen())),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          // Icon box
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: isDark ? _kDarkIconBox : _kLightIconBox,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.chat_bubble_outline_rounded,
              color: isDark ? Colors.white70 : const Color(0xFF2A2A2A), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chat Themes',
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: primaryText)),
              const SizedBox(height: 2),
              Text('Customize chat colors and wallpapers',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400,
                  color: isDark ? _kDarkSubtitle : _kLightSubtitle)),
            ],
          )),
          Icon(Icons.chevron_right_rounded,
            color: isDark ? _kDarkSubtitle : _kLightSubtitle, size: 22),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme option row (Dark / Light)
// ─────────────────────────────────────────────────────────────────────────────
class _ThemeRow extends StatelessWidget {
  final bool isDark;
  final Color primaryText;
  final Color divider;
  final String label;
  final bool isSelected;
  final Color circleColor;
  final VoidCallback onTap;
  final bool showDivider;

  const _ThemeRow({
    required this.isDark, required this.primaryText, required this.divider,
    required this.label, required this.isSelected, required this.circleColor,
    required this.onTap, required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            // Circle swatch
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0x26FFFFFF) : _kLightBorder,
                  width: 1,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label,
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400, color: primaryText))),
            // Green checkmark
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: isSelected
                ? Container(
                    key: const ValueKey('on'),
                    width: 26, height: 26,
                    decoration: const BoxDecoration(color: _kGreen, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                  )
                : const SizedBox(key: ValueKey('off'), width: 26, height: 26),
            ),
          ]),
        ),
      ),
      if (showDivider)
        Divider(height: 1, thickness: 1, color: divider, indent: 16, endIndent: 16),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Text size row — selected state uses a rounded pill container (no dividers)
// ─────────────────────────────────────────────────────────────────────────────
class _TextSizeRow extends StatelessWidget {
  final bool isDark;
  final Color primaryText;
  final String label;
  final double fontSize;
  final int index;
  final int selected;
  final VoidCallback onTap;

  const _TextSizeRow({
    required this.isDark,
    required this.primaryText,
    required this.label,
    required this.fontSize,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSel = index == selected;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSel
                ? (isDark ? _kSelectedRowDark : _kSelectedRowLight)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: fontSize,
                  fontWeight: isSel ? FontWeight.w500 : FontWeight.w400,
                  color: isSel
                      ? Colors.white
                      : (isDark ? const Color(0x99FFFFFF) : _kLightSubtitle),
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: isSel
                  ? Container(
                      key: const ValueKey('dot'),
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: _kOrange,
                        shape: BoxShape.circle,
                      ),
                    )
                  : const SizedBox(key: ValueKey('none'), width: 18, height: 18),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat Wallpaper row — 3 thumbnails + "Choose from Gallery"
// ─────────────────────────────────────────────────────────────────────────────

// Figma shows 3 wallpapers in the Themes & Appearance screen:
// teal-slate (asset_teal), aurora (asset_aurora), cosmos/purple (asset_cosmos)
// matching the 3 gradient thumbnails visible in the design
class _WallpaperRow extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final String selected;
  final ValueChanged<String> onSelect;

  const _WallpaperRow({
    required this.isDark, required this.cardBg,
    required this.selected, required this.onSelect,
  });

  static const _items = [
    _WpItem('asset_teal',   'assets/wallpapers/teal.png',
      LinearGradient(colors: [Color(0xFF1A6FA8), Color(0xFF2ABFBF)],
        begin: Alignment.topLeft, end: Alignment.bottomRight)),
    _WpItem('asset_aurora', 'assets/wallpapers/aurora.png',
      LinearGradient(colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4), Color(0xFFA1C4FD)],
        begin: Alignment.topLeft, end: Alignment.bottomRight)),
    _WpItem('asset_cosmos', 'assets/wallpapers/cosmos.png',
      LinearGradient(colors: [Color(0xFF7B2FF7), Color(0xFF4A148C)],
        begin: Alignment.topLeft, end: Alignment.bottomRight)),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? _kDarkBorder : _kLightBorder, width: 1),
        ),
        child: Column(children: [
          // Thumbnails
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: List.generate(_items.length, (i) {
                final item = _items[i];
                final isSel = selected == item.key;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
                    child: GestureDetector(
                      onTap: () => onSelect(item.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSel ? _kOrange : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(fit: StackFit.expand, children: [
                            Image.asset(item.assetPath, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                decoration: BoxDecoration(gradient: item.fallback))),
                            if (isSel)
                              Positioned(top: 5, right: 5,
                                child: Container(
                                  width: 18, height: 18,
                                  decoration: const BoxDecoration(color: _kOrange, shape: BoxShape.circle),
                                  child: const Icon(Icons.check, color: Colors.white, size: 11),
                                )),
                          ]),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Choose from Gallery
          InkWell(
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ChatThemesScreen())),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: Text('Choose from Gallery',
                  style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w500, color: _kOrange)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _WpItem {
  final String key;
  final String assetPath;
  final LinearGradient fallback;
  const _WpItem(this.key, this.assetPath, this.fallback);
}
