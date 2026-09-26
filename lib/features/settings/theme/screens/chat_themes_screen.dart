import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qik_talk/features/settings/theme/models/wallpaper_item.dart';
import 'package:qik_talk/features/settings/theme/provider/chat_theme_provider.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/components/buttons/custom_back_button.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────────────────────────────────────
const _kOrange        = Color(0xFFFF8C00);
const _kScaffold      = Color(0xFF141414);
const _kLabel         = Color(0xFF6B6B6B);
const _kLightScaffold = Color(0xFFFAF5F0);
const _kLightCard     = Color(0xFFF2EDE8);
const _kLightBorder   = Color(0xFFCFC4B5);
const _kLightLabel    = Color(0xFF4A4A4A);

// ─────────────────────────────────────────────────────────────────────────────
// Chat theme presets
// bgGradient   : colored gradient filling the inner card area
// topPillColor : wider top pill (receiver), semi-transparent
// botPillColor : shorter bottom pill (sender), semi-transparent, right-aligned
// receiverPill : live preview left-bubble color
// senderPill   : live preview right-bubble color
// ─────────────────────────────────────────────────────────────────────────────
class _Preset {
  final String key, label;
  final Gradient bgGradient;
  final Color topPillColor;
  final Color botPillColor;
  final Color receiverPill;
  final Color senderPill;
  const _Preset(this.key, this.label, this.bgGradient,
      this.topPillColor, this.botPillColor, this.receiverPill, this.senderPill);
}

const _kPresets = [
  // Default — dark navy bg, semi-transparent grey pills
  _Preset('default', 'Default',
    LinearGradient(colors: [Color(0xFF1A2A3A), Color(0xFF0D1520)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    Color(0x663A4A5A), Color(0x443A4A5A),
    Color(0xFF3C3C3C), Color(0xFF8B7B5E)),
  // Sunset — orange→red, salmon top, yellow bottom
  _Preset('sunset', 'Sunset',
    LinearGradient(colors: [Color(0xFFFF5722), Color(0xFFE91E1E)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    Color(0x99FF8A65), Color(0xCCFFD740),
    Color(0xFFE64A19), Color(0xFFFFAB40)),
  // Ocean — blue gradient, cyan top, dark blue bottom
  _Preset('ocean', 'Ocean',
    LinearGradient(colors: [Color(0xFF1E88E5), Color(0xFF0D47A1)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    Color(0xCC26C6DA), Color(0x991565C0),
    Color(0xFF00BCD4), Color(0xFF1565C0)),
  // Forest — green gradient, light green top, dark green bottom
  _Preset('forest', 'Forest',
    LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    Color(0xCC66BB6A), Color(0x991B5E20),
    Color(0xFF43A047), Color(0xFF1B5E20)),
  // Lavender — purple gradient, light lavender pills
  _Preset('lavender', 'Lavender',
    LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    Color(0xCCCE93D8), Color(0x99CE93D8),
    Color(0xFFCE93D8), Color(0xFF7B1FA2)),
  // Midnight — dark indigo, subtle indigo pills
  _Preset('midnight', 'Midnight',
    LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF0D1340)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    Color(0x663949AB), Color(0x443949AB),
    Color(0xFF42A5F5), Color(0xFF0D1B2A)),
  // Autumn — amber→burnt-orange, light amber top, dark orange bottom
  _Preset('autumn', 'Autumn',
    LinearGradient(colors: [Color(0xFFFF8F00), Color(0xFFBF360C)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    Color(0xCCFFCC80), Color(0x99E65100),
    Color(0xFFFFCC80), Color(0xFFE64A19)),
  // Rose — pink→deep-pink, light pink top, deep pink bottom
  _Preset('rose', 'Rose',
    LinearGradient(colors: [Color(0xFFE91E8C), Color(0xFFB71C5A)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    Color(0xCCF48FB1), Color(0x99AD1457),
    Color(0xFFF48FB1), Color(0xFFE91E8C)),
];

// ─────────────────────────────────────────────────────────────────────────────
// Bubble color palette — 9 swatches in a single row (matches design)
// ─────────────────────────────────────────────────────────────────────────────
const _kBubbleColors = [
  Color(0xFF9E9E9E), // grey
  Color(0xFFFF8C00), // orange
  Color(0xFF9C27B0), // purple
  Color(0xFFE53935), // red
  Color(0xFFE91E63), // pink-red
  Color(0xFF1E88E5), // blue
  Color(0xFF1565C0), // dark blue
  Color(0xFF424242), // dark grey
  Color(0xFF212121), // near black
];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────
class ChatThemesScreen extends ConsumerStatefulWidget {
  const ChatThemesScreen({super.key});

  @override
  ConsumerState<ChatThemesScreen> createState() => _ChatThemesScreenState();
}

class _ChatThemesScreenState extends ConsumerState<ChatThemesScreen> {
  String? _pendingTheme;
  Color?  _pendingBubble;
  String? _pendingWallpaper;

  bool get _isDark {
    final mode = ref.watch(themeProvider);
    final sys  = MediaQuery.of(context).platformBrightness;
    return mode == ThemeMode.dark ||
        (mode == ThemeMode.system && sys == Brightness.dark);
  }

  String _theme(ChatThemeState s)     => _pendingTheme     ?? s.chatTheme;
  String _wallpaper(ChatThemeState s) => _pendingWallpaper ?? s.wallpaperKey;

  Color _senderColor(ChatThemeState s) {
    if (_pendingBubble != null) return _pendingBubble!;
    final t = _theme(s);
    return _kPresets
        .firstWhere((p) => p.key == t, orElse: () => _kPresets.first)
        .senderPill;
  }

  Color _receiverColor(ChatThemeState s) {
    final t = _theme(s);
    return _kPresets
        .firstWhere((p) => p.key == t, orElse: () => _kPresets.first)
        .receiverPill;
  }

  Future<void> _apply(ChatThemeState s) async {
    final n = ref.read(chatThemeProvider.notifier);
    if (_pendingTheme    != null) await n.setChatTheme(_pendingTheme!);
    if (_pendingBubble   != null) await n.setBubbleColor(_pendingBubble);
    if (_pendingWallpaper != null) {
      await n.setWallpaper(_pendingWallpaper!);
    }

    // ── Resolve the effective theme and colors after applying ──────────────
    final effectiveTheme = _pendingTheme ?? s.chatTheme;
    final themeState     = ChatThemeState(
      chatTheme:      effectiveTheme,
      bubbleColorHex: _pendingBubble != null
          ? _pendingBubble!.toARGB32().toRadixString(16).padLeft(8, '0')
          : s.bubbleColorHex,
    );

    // ── Write resolved colors to SharedPreferences so both chat screens
    //    pick them up immediately via _loadWallpaperAndColor() ──────────────
    final prefs = await SharedPreferences.getInstance();
    final senderColor   = themeState.senderBubbleColor(true);
    final receiverColor = themeState.receiverBubbleColor(true);
    final senderGlow    = themeState.senderGlowColor();
    final receiverGlow  = themeState.receiverGlowColor();
    await prefs.setInt('global_bubble_color',    senderColor.toARGB32());
    await prefs.setInt('global_receiver_color',  receiverColor.toARGB32());
    await prefs.setInt('global_sender_glow',     senderGlow.toARGB32());
    await prefs.setInt('global_receiver_glow',   receiverGlow.toARGB32());
    await prefs.setString('chat_theme_preset',   effectiveTheme);

    if (!mounted) return;
    setState(() {
      _pendingTheme     = null;
      _pendingBubble    = null;
      _pendingWallpaper = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Theme applied',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white)),
      backgroundColor: _kOrange,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  Future<void> _reset() async {
    await ref.read(chatThemeProvider.notifier).resetToDefault();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('global_wallpaper');
    await prefs.remove('global_bubble_color');
    await prefs.remove('global_receiver_color');
    await prefs.remove('global_sender_glow');
    await prefs.remove('global_receiver_glow');
    await prefs.remove('chat_theme_preset');
    if (!mounted) return;
    setState(() {
      _pendingTheme     = null;
      _pendingBubble    = null;
      _pendingWallpaper = null;
    });
  }

  Future<void> _gallery() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      setState(() => _pendingWallpaper = picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(chatThemeProvider);
    final isDark    = _isDark;
    return Scaffold(
      backgroundColor: isDark ? _kScaffold : _kLightScaffold,
      appBar: _buildAppBar(),
      body: chatAsync.when(
        loading: () => const SizedBox.shrink(),
        error:   (e, _) => Center(child: Text('Error: $e')),
        data:    (s) => _buildBody(s, isDark),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() => PreferredSize(
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
        title: Text('Chat Themes',
            style: GoogleFonts.poppins(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    ),
  );

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody(ChatThemeState s, bool isDark) {
    final labelColor = isDark ? _kLabel : _kLightLabel;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PREVIEW
          _SectionLabel('PREVIEW', labelColor),
          const SizedBox(height: 10),
          _buildPreview(s, isDark),
          const SizedBox(height: 24),

          // CHAT THEME
          _SectionLabel('CHAT THEME', labelColor),
          const SizedBox(height: 10),
          _buildThemeGrid(s, isDark),
          const SizedBox(height: 24),

          // CHAT COLOR (YOUR BUBBLES)
          _SectionLabel('CHAT COLOR (YOUR BUBBLES)', labelColor),
          const SizedBox(height: 12),
          _buildBubbleColorRow(s),
          const SizedBox(height: 10),
          _buildCustomColorRow(isDark),
          const SizedBox(height: 24),

          // CHAT WALLPAPER
          _SectionLabel('CHAT WALLPAPER', labelColor),
          const SizedBox(height: 10),
          _buildWallpaperGrid(s, isDark),
          const SizedBox(height: 16),

          // SOLID COLORS
          _SectionLabel('SOLID COLORS', labelColor),
          const SizedBox(height: 10),
          _buildSolidColors(s, isDark),
          const SizedBox(height: 24),

          // BOTTOM BUTTONS
          _buildBottomButtons(s, isDark),
        ],
      ),
    );
  }

  // ── Preview ────────────────────────────────────────────────────────────────
  // Compact card matching the design: ~165px tall, teal-to-navy gradient bg,
  // three chat bubbles in the lower portion.
  Widget _buildPreview(ChatThemeState s, bool isDark) {
    final wpKey    = _wallpaper(s);
    final sender   = _senderColor(s);
    final receiver = _receiverColor(s);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 165,
        width: double.infinity,
        child: Stack(fit: StackFit.expand, children: [
          _wallpaperBg(wpKey, isDark),
          // Bubbles pinned to bottom
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _previewBubble('Hey! How are you?', receiver, isReceiver: true),
                  ),
                  const SizedBox(height: 7),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _previewBubble("I'm doing great, thanks!", sender),
                  ),
                  const SizedBox(height: 7),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _previewBubble("That's wonderful 🎉", receiver, isReceiver: true),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _wallpaperBg(String key, bool isDark) {
    if (key == 'none') {
      // Teal-to-dark-navy gradient — matches the design preview background
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2A7FA8), Color(0xFF1A4E7A), Color(0xFF0D2340)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
      );
    }
    final assetItem = BuiltInWallpapers.assetWallpapers
        .where((w) => w.key == key).firstOrNull;
    if (assetItem != null && assetItem.assetPath != null) {
      return Image.asset(assetItem.assetPath!, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Container(decoration: BoxDecoration(gradient: assetItem.fallbackGradient)));
    }
    if (key.startsWith('solid_')) {
      final item = BuiltInWallpapers.solidColors
          .firstWhere((w) => w.key == key, orElse: () => BuiltInWallpapers.solidBlack);
      return Container(color: item.solidColor);
    }
    return Image.file(File(key), fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
            color: isDark ? const Color(0xFF1A3A5C) : const Color(0xFFE8E0D8)));
  }

  Widget _previewBubble(String text, Color bg, {bool isReceiver = false}) =>
      Container(
        constraints: const BoxConstraints(maxWidth: 220),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(18),
            topRight:    const Radius.circular(18),
            bottomLeft:  Radius.circular(isReceiver ? 3 : 18),
            bottomRight: Radius.circular(isReceiver ? 18 : 3),
          ),
        ),
        child: Text(text,
            style: GoogleFonts.poppins(
                fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.w400)),
      );

  // ── Theme Grid — 2 cols × 4 rows ──────────────────────────────────────────
  // Design: gradient fills the entire upper portion of the card (no inset),
  // label sits in a dark strip below. Pills are centered vertically inside
  // the gradient area — top pill left-aligned ~80%, bottom pill right-aligned ~55%.
  Widget _buildThemeGrid(ChatThemeState s, bool isDark) {
    final sel       = _theme(s);
    final outerBg   = isDark ? const Color(0xFF1C1C1E) : _kLightCard;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1008);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.45,
      ),
      itemCount: _kPresets.length,
      itemBuilder: (_, i) {
        final p     = _kPresets[i];
        final isSel = p.key == sel;

        return GestureDetector(
          onTap: () => setState(() => _pendingTheme = p.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: outerBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSel
                    ? Colors.white
                    : (isDark ? const Color(0xFF2C2C2E) : _kLightBorder),
                width: isSel ? 2 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Stack(
                children: [
                  // ── Full card layout: gradient top + label bottom ─────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Gradient fills ~70% of card — no inset, edge-to-edge
                      Expanded(
                        flex: 68,
                        child: Container(
                          decoration: BoxDecoration(gradient: p.bgGradient),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Top pill — receiver, left-aligned, ~80% width
                                FractionallySizedBox(
                                  widthFactor: 0.80,
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    height: 17,
                                    decoration: BoxDecoration(
                                      color: p.topPillColor,
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Bottom pill — sender, right-aligned, ~55% width
                                FractionallySizedBox(
                                  widthFactor: 0.55,
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    height: 17,
                                    decoration: BoxDecoration(
                                      color: p.botPillColor,
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Label strip — dark background, 32% of card height
                      Expanded(
                        flex: 32,
                        child: Container(
                          color: outerBg,
                          child: Center(
                            child: Text(
                              p.label,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ── Orange checkmark badge — top-right of gradient area ───
                  if (isSel)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: _kOrange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Bubble color row — 9 circles in a single row ──────────────────────────
  // Design shows swatches directly on the scaffold (no card wrapper),
  // evenly spaced in one horizontal row.
  Widget _buildBubbleColorRow(ChatThemeState s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_kBubbleColors.length, (i) {
        final c = _kBubbleColors[i];
        final isSel = _pendingBubble == c ||
            (_pendingBubble == null &&
                s.bubbleColorHex != null &&
                Color(int.parse(s.bubbleColorHex!, radix: 16)) == c);
        return GestureDetector(
          onTap: () => setState(() => _pendingBubble = c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: isSel
                  ? Border.all(color: Colors.white, width: 2.5)
                  : null,
            ),
            child: isSel
                ? const Icon(Icons.check, size: 15, color: Colors.white)
                : null,
          ),
        );
      }),
    );
  }

  // ── Custom Color row ───────────────────────────────────────────────────────
  // Dark card with "Custom Color" text left, dark rounded square right.
  Widget _buildCustomColorRow(bool isDark) {
    final cardBg    = isDark ? const Color(0xFF1A1A1C) : _kLightCard;
    final cardBorder = isDark ? const Color(0xFF2C2C2E) : _kLightBorder;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1008);

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorder),
      ),
      child: Row(children: [
        Text('Custom Color',
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w400, color: textColor)),
        const Spacer(),
        // Dark rounded square — color picker trigger
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFDDD3C5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? const Color(0xFF3A3A3C) : _kLightBorder,
            ),
          ),
        ),
      ]),
    );
  }

  // ── Wallpaper grid — 3 cols × 3 rows ──────────────────────────────────────
  Widget _buildWallpaperGrid(ChatThemeState s, bool isDark) {
    final wallpapers = BuiltInWallpapers.assetWallpapers;
    final selKey     = _wallpaper(s);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 7,
        mainAxisSpacing: 7,
        childAspectRatio: 0.65,
      ),
      itemCount: wallpapers.length,
      itemBuilder: (_, i) {
        final item  = wallpapers[i];
        final isSel = item.key == selKey;
        return GestureDetector(
          onTap: () => setState(() => _pendingWallpaper = item.key),
          child: Stack(fit: StackFit.expand, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: item.assetPath != null
                  ? Image.asset(item.assetPath!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          decoration: BoxDecoration(gradient: item.fallbackGradient)))
                  : Container(decoration: BoxDecoration(gradient: item.fallbackGradient)),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSel ? _kOrange : Colors.transparent,
                  width: 2.5,
                ),
              ),
            ),
            if (isSel)
              Positioned(
                top: 6, right: 6,
                child: Container(
                  width: 20, height: 20,
                  decoration: const BoxDecoration(color: _kOrange, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ),
          ]),
        );
      },
    );
  }

  // ── Solid colors — 4 squares ───────────────────────────────────────────────
  // Design: black, dark charcoal, white, off-white — rounded corners (~14px),
  // moderate height (~65px), no border when unselected.
  Widget _buildSolidColors(ChatThemeState s, bool isDark) {
    final solids = BuiltInWallpapers.solidColors;
    final selKey = _wallpaper(s);

    return Row(
      children: List.generate(solids.length, (i) {
        final item  = solids[i];
        final isSel = item.key == selKey;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _pendingWallpaper = item.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 65,
              margin: EdgeInsets.only(right: i < solids.length - 1 ? 10 : 0),
              decoration: BoxDecoration(
                color: item.solidColor,
                borderRadius: BorderRadius.circular(14),
                border: isSel
                    ? Border.all(color: _kOrange, width: 2.5)
                    : null,
              ),
              child: isSel
                  ? Center(
                      child: Container(
                        width: 20, height: 20,
                        decoration: const BoxDecoration(
                            color: _kOrange, shape: BoxShape.circle),
                        child: const Icon(Icons.check, color: Colors.white, size: 12),
                      ),
                    )
                  : null,
            ),
          ),
        );
      }),
    );
  }

  // ── Bottom Buttons ─────────────────────────────────────────────────────────
  // Design:
  //   1. "Choose from Gallery" — dark brown gradient (medium-brown → near-black)
  //   2. "Reset to Default"    — very dark container, almost invisible, muted text
  //   3. "Apply Theme"         — same dark brown gradient as Choose from Gallery
  Widget _buildBottomButtons(ChatThemeState s, bool isDark) {
    // Dark brown gradient: visible brown on left fading to near-black on right
    const darkBrownGradient = LinearGradient(
      colors: [Color(0xFF7A3A08), Color(0xFF1E0A00)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    const buttonRadius = 28.0;
    const buttonHeight = 54.0;

    // Reset button: very dark container, almost invisible against scaffold
    final resetBg   = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFE8E0D8);
    final resetText = isDark ? const Color(0xFF6B6B6B) : _kLightLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        // ── Choose from Gallery ─────────────────────────────────────────────
        GestureDetector(
          onTap: _gallery,
          child: Container(
            height: buttonHeight,
            decoration: BoxDecoration(
              gradient: darkBrownGradient,
              borderRadius: BorderRadius.circular(buttonRadius),
            ),
            child: Center(
              child: Text(
                'Choose from Gallery',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ── Reset to Default — dark container, barely visible ───────────────
        GestureDetector(
          onTap: _reset,
          child: Container(
            height: buttonHeight,
            decoration: BoxDecoration(
              color: resetBg,
              borderRadius: BorderRadius.circular(buttonRadius),
            ),
            child: Center(
              child: Text(
                'Reset to Default',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: resetText,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ── Apply Theme ─────────────────────────────────────────────────────
        GestureDetector(
          onTap: () => _apply(s),
          child: Container(
            height: buttonHeight,
            decoration: BoxDecoration(
              gradient: darkBrownGradient,
              borderRadius: BorderRadius.circular(buttonRadius),
            ),
            child: Center(
              child: Text(
                'Apply Theme',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionLabel(this.text, this.color);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 1.2,
    ),
  );
}
