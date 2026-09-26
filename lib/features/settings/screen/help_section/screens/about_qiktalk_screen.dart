import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../../../../utilities/constants/app_colors.dart';
import '../../../../../utilities/constants/app_theme.dart';
import '../../../theme/provider/theme_provider.dart';

class AboutQikTalkScreen extends ConsumerWidget {
  const AboutQikTalkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    final bool isDark =
        currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);

    final double topPadding = MediaQuery.of(context).padding.top + 10;

    final Color textMain = isDark ? Colors.white : Colors.black87;
    final Color textSub =
        isDark ? Colors.white.withOpacity(0.55) : Colors.black54;
    final Color sectionLabelColor =
        isDark ? Colors.white.withOpacity(0.45) : Colors.grey.shade500;
    final Color statCardBorder =
        isDark ? Colors.white.withOpacity(0.12) : Colors.grey.shade300;
    final Color statCardBg =
        isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade50;

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
                          'About QikTalk',
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // ── Logo + app name + version ───────────────────────────
                  Center(
                    child: Column(
                      children: [
                        // QikTalk logo with text
                        Image.asset(
                          'images/splash_screen_logo.png',
                          height: 80,
                          width: 160,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Qiktalk',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: textMain,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Version 2.0.0',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: textSub,
                          ),
                        ),
                        Text(
                          'Build 2024.12.08',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: textSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Our Mission ─────────────────────────────────────────
                  Text(
                    'Our Mission',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: textMain,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Qiktalk is dedicated to providing secure, private, and feature-rich communication for everyone. We believe in connecting people while respecting their privacy and data.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                      color: textSub,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ── WHY QIKTALK ─────────────────────────────────────────
                  Text(
                    'WHY QIKTALK',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: sectionLabelColor,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Privacy First — green circle icon
                  _whyRow(
                    svgPath: 'assets/svgs/shield_lock.svg',
                    iconBg: const Color(0xFF1A6B3C),
                    iconColor: const Color(0xFF4ADE80),
                    title: 'Privacy First',
                    subtitle: 'End-to-end encryption for all your messages and calls',
                    textMain: textMain,
                    textSub: textSub,
                  ),
                  const SizedBox(height: 16),

                  // Fast & Reliable — blue circle icon
                  _whyRow(
                    svgPath: 'assets/svgs/lightning_bolt.svg',
                    iconBg: const Color(0xFF1A4A8A),
                    iconColor: const Color(0xFF60A5FA),
                    title: 'Fast & Reliable',
                    subtitle: 'Lightning-fast message delivery across the globe',
                    textMain: textMain,
                    textSub: textSub,
                  ),
                  const SizedBox(height: 16),

                  // Community Focused — purple circle icon
                  _whyRow(
                    svgPath: 'assets/svgs/community_people.svg',
                    iconBg: const Color(0xFF6B2FA0),
                    iconColor: const Color(0xFFC084FC),
                    title: 'Community Focused',
                    subtitle: 'Highlighting meaningful delivery across the globe',
                    textMain: textMain,
                    textSub: textSub,
                  ),
                  const SizedBox(height: 16),

                  // Global Reach — gold/yellow circle icon
                  _whyRow(
                    svgPath: 'assets/svgs/globe_world.svg',
                    iconBg: const Color(0xFF8A6A00),
                    iconColor: const Color(0xFFFACC15),
                    title: 'Global Reach',
                    subtitle: 'Connect with anyone, anywhere in the world',
                    textMain: textMain,
                    textSub: textSub,
                  ),
                  const SizedBox(height: 24),

                  // ── BY THE NUMBERS ──────────────────────────────────────
                  Text(
                    'BY THE NUMBERS',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: sectionLabelColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          value: '500M+',
                          label: 'Active users',
                          border: statCardBorder,
                          bg: statCardBg,
                          textMain: textMain,
                          textSub: textSub,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                          value: '100B+',
                          label: 'Messages Daily',
                          border: statCardBorder,
                          bg: statCardBg,
                          textMain: textMain,
                          textSub: textSub,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          value: '180+',
                          label: 'Countries',
                          border: statCardBorder,
                          bg: statCardBg,
                          textMain: textMain,
                          textSub: textSub,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                          value: '99.9%',
                          label: 'Uptime',
                          border: statCardBorder,
                          bg: statCardBg,
                          textMain: textMain,
                          textSub: textSub,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── AWARDS & RECOGNITION ────────────────────────────────
                  Text(
                    'AWARDS & RECOGNITION',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: sectionLabelColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _awardRow(
                    title: 'Best Mobile App 2024',
                    subtitle: 'Tech Awards',
                    textMain: textMain,
                    textSub: textSub,
                  ),
                  _awardRow(
                    title: 'Privacy Champion',
                    subtitle: 'Digital Rights Foundation',
                    textMain: textMain,
                    textSub: textSub,
                  ),
                  _awardRow(
                    title: 'Innovation Award',
                    subtitle: 'Mobile World Congress',
                    textMain: textMain,
                    textSub: textSub,
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── WHY row — no card background, just icon circle + text ──────────────────
  Widget _whyRow({
    required String svgPath,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color textMain,
    required Color textSub,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              svgPath,
              height: 22,
              width: 22,
              colorFilter: ColorFilter.mode(
                iconColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: textMain,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: textSub,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Stat card — outlined, no fill ──────────────────────────────────────────
  Widget _statCard({
    required String value,
    required String label,
    required Color border,
    required Color bg,
    required Color textMain,
    required Color textSub,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: textMain,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: textSub,
            ),
          ),
        ],
      ),
    );
  }

  // ── Award row — gold trophy icon, no dividers ───────────────────────────────
  Widget _awardRow({
    required String title,
    required String subtitle,
    required Color textMain,
    required Color textSub,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF8A6A00).withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/svgs/award_medal.svg',
                height: 22,
                width: 22,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFFACC15),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textMain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: textSub,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
