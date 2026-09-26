import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../../../../utilities/constants/app_colors.dart';
import '../../../../../utilities/constants/app_theme.dart';
import '../../../theme/provider/theme_provider.dart';
import 'contact_support_screen.dart';
import 'help_screen.dart';

class FaqDetailScreen extends ConsumerStatefulWidget {
  final FaqItem faqItem;

  const FaqDetailScreen({super.key, required this.faqItem});

  @override
  ConsumerState<FaqDetailScreen> createState() => _FaqDetailScreenState();
}

class _FaqDetailScreenState extends ConsumerState<FaqDetailScreen> {
  // null = not answered, true = yes, false = no
  bool? _wasHelpful;

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    final bool isDark =
        currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);

    final double topPadding = MediaQuery.of(context).padding.top + 10;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : AppTheme.scaffoldBg(isDark),
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : AppTheme.scaffoldBg(isDark),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: isDark ? HexColor('#3A1D07') : AppTheme.scaffoldBg(isDark),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                image: isDark ? const DecorationImage(
                  image: AssetImage('images/app_bar_gredient.png'),
                  fit: BoxFit.cover,
                ) : null,
                color: isDark ? null : AppTheme.scaffoldBg(isDark),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: topPadding,
                            left: 16.0,
                            right: 16.0,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            size: 22.0,
                            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: topPadding),
                        child: Text(
                          'FAQ',
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        // ── Question ──────────────────────────────────────
                        Text(
                          widget.faqItem.question,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // ── Answer blocks ─────────────────────────────────
                        ...widget.faqItem.blocks.map(
                          (block) => _buildBlock(block, isDark),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Was this helpful? ─────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark
                    ? Color(AppColors.primaryBackgroundColor)
                    : AppTheme.scaffoldBg(isDark),
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.shade200,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  20,
                  16,
                  MediaQuery.of(context).padding.bottom + 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Was this helpful?',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        // Yes button
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _wasHelpful = true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 48,
                              decoration: BoxDecoration(
                                color: _wasHelpful == true
                                    ? Colors.green.withOpacity(0.15)
                                    : isDark
                                        ? Color(AppColors.primaryColor)
                                            .withOpacity(0.5)
                                        : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: _wasHelpful == true
                                    ? Border.all(
                                        color: Colors.green.withOpacity(0.5),
                                      )
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.thumb_up_outlined,
                                    size: 18,
                                    color: _wasHelpful == true
                                        ? Colors.green
                                        : isDark
                                            ? Colors.white
                                            : Colors.black87,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Yes',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: _wasHelpful == true
                                          ? Colors.green
                                          : isDark
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // No button
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _wasHelpful = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 48,
                              decoration: BoxDecoration(
                                color: _wasHelpful == false
                                    ? Colors.red.withOpacity(0.12)
                                    : isDark
                                        ? Color(AppColors.primaryColor)
                                            .withOpacity(0.5)
                                        : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: _wasHelpful == false
                                    ? Border.all(
                                        color: Colors.red.withOpacity(0.4),
                                      )
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.thumb_down_outlined,
                                    size: 18,
                                    color: _wasHelpful == false
                                        ? Colors.red
                                        : isDark
                                            ? Colors.white
                                            : Colors.black87,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'No',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: _wasHelpful == false
                                          ? Colors.red
                                          : isDark
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // ── Still need help? ──────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Color(AppColors.primaryColor).withOpacity(0.3)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Still need help?',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ContactSupportScreen(),
                              ),
                            ),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.scaffoldBg(isDark),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/svgs/contact_support_bubble.svg',
                                    height: 16,
                                    width: 16,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.blue,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Contact support',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Block renderer ──────────────────────────────────────────────────────────
  Widget _buildBlock(FaqBlock block, bool isDark) {
    final Color textColor =
        isDark ? Colors.white.withOpacity(0.85) : Colors.black87;
    final Color mutedColor =
        isDark ? Colors.white.withOpacity(0.55) : Colors.black54;

    switch (block.type) {
      // Plain paragraph — intro lines, section labels
      case FaqBlockType.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            block.text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.6,
              color: textColor,
            ),
          ),
        );

      // Numbered step  e.g. "1. Go to Settings"
      case FaqBlockType.numbered:
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${block.number}. ',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
              ),
              Expanded(
                child: Text(
                  block.text,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        );

      // Bullet point  e.g. "• Cannot call or message you"
      case FaqBlockType.bullet:
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: textColor,
                ),
              ),
              Expanded(
                child: Text(
                  block.text,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        );

      // Note — closing remark, rendered in muted colour with top spacing
      case FaqBlockType.note:
        return Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 8),
          child: Text(
            block.text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.6,
              color: mutedColor,
            ),
          ),
        );
    }
  }
}
