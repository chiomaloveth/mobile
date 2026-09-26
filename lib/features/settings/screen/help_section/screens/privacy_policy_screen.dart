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

class PrivacyPolicyScreen extends ConsumerStatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  ConsumerState<PrivacyPolicyScreen> createState() =>
      _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends ConsumerState<PrivacyPolicyScreen> {
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
    final Color textMain = isDark ? Colors.white : Colors.black87;
    final Color textSub =
        isDark ? Colors.white.withOpacity(0.7) : Colors.black87;

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
                          'Privacy Policy',
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
                        const SizedBox(height: 20),
                        Text(
                          'At QikTalk, your privacy matters. This policy explains what we collect, how we use it, and how we keep your data safe.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1.6,
                            color: textSub,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Section 1 ───────────────────────────────────
                        _sectionTitle('1. What We Collect', textMain),
                        _subTitle('Account Information', textMain),
                        _bullet('Name, username, email, phone number', textSub),
                        _subTitle('Usage Data', textMain),
                        _bullet('Messages, interactions, app activity', textSub),
                        _subTitle('Device Information', textMain),
                        _bullet('Device type, OS, IP address', textSub),
                        _subTitle('Optional Data', textMain),
                        _bullet('Profile photo, bio, contacts (If you allow access)', textSub),
                        const SizedBox(height: 16),

                        // ── Section 2 ───────────────────────────────────
                        _sectionTitle('2. How We Use Your Data', textMain),
                        _paragraph('We use your data to:', textSub),
                        _bullet('Provide and improve QikTalk features', textSub),
                        _bullet('Personalize your experience', textSub),
                        _bullet('Keep the platform safe and secure', textSub),
                        _bullet('Communicate updates or important notices', textSub),
                        const SizedBox(height: 16),

                        // ── Section 3 ───────────────────────────────────
                        _sectionTitle('3. Messages & Privacy', textMain),
                        _paragraph('Your conversations are private.', textSub),
                        _paragraph(
                            ' We do not sell your messages or personal data.',
                            textSub),
                        _paragraph(
                            '(Some features like moderation or reporting may require limited review.)',
                            textSub),
                        const SizedBox(height: 16),

                        // ── Section 4 ───────────────────────────────────
                        _sectionTitle('4. Sharing Your Information', textMain),
                        _paragraph('We only share data when:', textSub),
                        _bullet('Required by law', textSub),
                        _bullet('Needed to prevent fraud or abuse', textSub),
                        _bullet('Working with trusted service providers', textSub),
                        const SizedBox(height: 16),

                        // ── Section 5 ───────────────────────────────────
                        _sectionTitle('5. Your Choices', textMain),
                        _paragraph('You can:', textSub),
                        _bullet('Update or delete your account anytime', textSub),
                        _bullet('Control permissions (camera, contacts, etc.)', textSub),
                        _bullet('Manage notifications', textSub),
                        const SizedBox(height: 16),

                        // ── Section 6 ───────────────────────────────────
                        _sectionTitle('6. Data Security', textMain),
                        _paragraph(
                            'We use industry-standard security measures to protect your information.',
                            textSub),
                        const SizedBox(height: 16),

                        // ── Section 7 ───────────────────────────────────
                        _sectionTitle('7. Changes to This Policy', textMain),
                        _paragraph(
                            'We may update this policy. We\'ll notify you of major changes.',
                            textSub),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Was this helpful? ───────────────────────────────────────
            _helpfulFooter(isDark, context),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: color,
          ),
        ),
      );

  Widget _subTitle(String text, Color color) => Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 2),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: color,
          ),
        ),
      );

  Widget _paragraph(String text, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.6,
            color: color,
          ),
        ),
      );

  Widget _bullet(String text, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 4, left: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('•  ',
                style: GoogleFonts.poppins(fontSize: 13, color: color)),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _helpfulFooter(bool isDark, BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Color(AppColors.primaryBackgroundColor) : AppColors.lightNavBar,
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
                                ? Color(AppColors.primaryColor).withOpacity(0.5)
                                : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: _wasHelpful == true
                            ? Border.all(color: Colors.green.withOpacity(0.5))
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.thumb_up_outlined,
                              size: 18,
                              color: _wasHelpful == true
                                  ? Colors.green
                                  : isDark
                                      ? Colors.white
                                      : Colors.black87),
                          const SizedBox(width: 8),
                          Text('Yes',
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: _wasHelpful == true
                                      ? Colors.green
                                      : isDark
                                          ? Colors.white
                                          : Colors.black87)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                                ? Color(AppColors.primaryColor).withOpacity(0.5)
                                : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: _wasHelpful == false
                            ? Border.all(color: Colors.red.withOpacity(0.4))
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.thumb_down_outlined,
                              size: 18,
                              color: _wasHelpful == false
                                  ? Colors.red
                                  : isDark
                                      ? Colors.white
                                      : Colors.black87),
                          const SizedBox(width: 8),
                          Text('No',
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: _wasHelpful == false
                                      ? Colors.red
                                      : isDark
                                          ? Colors.white
                                          : Colors.black87)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
                          builder: (_) => const ContactSupportScreen()),
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
                          Text('Contact support',
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue)),
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
    );
  }
}
