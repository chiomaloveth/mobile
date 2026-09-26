import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/settings/account/screens/two_step_verification/create_pin_screen.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

class TwoStepIntroScreen extends ConsumerStatefulWidget {
  const TwoStepIntroScreen({super.key});

  @override
  ConsumerState<TwoStepIntroScreen> createState() => _TwoStepIntroScreenState();
}

class _TwoStepIntroScreenState extends ConsumerState<TwoStepIntroScreen> {
  bool _is2FAEnabled = false;
  bool _isDisabling = false;

  @override
  void initState() {
    super.initState();
    _fetch2FAStatus();
  }

  Future<void> _fetch2FAStatus() async {
    try {
      final token = await SaveValues().getString(AppPreferenceHelper.AUTH_TOKEN);
      final response = await http.get(
        Uri.parse(ApiStrings.twoFaStatus),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print('2FA status ${response.statusCode}: ${response.body}');
      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(response.body);
          // Response: { "success": true, "data": { "enabled": true, ... } }
          final dynamic payload = data['data'] ?? data;
          final bool enabled = payload['enabled'] == true ||
              payload['isEnabled'] == true ||
              payload['twoFactorEnabled'] == true;
          setState(() {
            _is2FAEnabled = enabled;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _disable2FA() async {
    // Ask for confirmation code before disabling
    final codeController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (ctx) => _DisableConfirmDialog(codeController: codeController),
    );
    if (confirmed != true || !mounted) return;

    final code = codeController.text.trim();
    if (code.isEmpty) return;

      setState(() => _isDisabling = true);
    try {
      final token = await SaveValues().getString(AppPreferenceHelper.AUTH_TOKEN);
      // POST /api/v1/auth/security/two-factor/disable — body: { "pin": "123456" }
      final response = await http.post(
        Uri.parse(ApiStrings.twoFaDisable),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'pin': code}),
      );

      print('2FA disable ${response.statusCode}: ${response.body}');
      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _is2FAEnabled = false;
          _isDisabling = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Two-step verification has been disabled.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _isDisabling = false);
        String message = 'Failed to disable two-step verification.';
        try {
          final body = jsonDecode(response.body);
          message = body['message'] ?? message;
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDisabling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);
    final double topPadding = MediaQuery.of(context).padding.top + 10;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor:
            isDark ? Color(AppColors.primaryBackgroundColor) : AppColors.lightNavBar,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor:
            isDark ? Color(AppColors.primaryBackgroundColor) : AppColors.lightNavBar,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: isDark ? HexColor("#3A1D07") : AppTheme.scaffoldBg(isDark),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                image: isDark
                    ? const DecorationImage(
                        image: AssetImage("images/app_bar_gredient.png"),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: isDark ? null : AppTheme.scaffoldBg(isDark),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: topPadding,
                            left: 16.0,
                            right: 40.0,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            size: 22.0,
                            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: topPadding, left: 10.0),
                        child: Text(
                          "Two-Step Verification",
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
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
        body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      // Shield icon — green if enabled, grey if disabled
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: _is2FAEnabled
                                ? const Color(0xFF1A3A2A)
                                : const Color(0xFF2A2A2A),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _is2FAEnabled
                                ? Icons.shield
                                : Icons.shield_outlined,
                            color: _is2FAEnabled
                                ? const Color(0xFF34C759)
                                : Colors.grey,
                            size: 48,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Center(
                        child: Text(
                          _is2FAEnabled
                              ? 'Two-Step Verification is On'
                              : 'Add Extra Security',
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          _is2FAEnabled
                              ? 'Your account is protected with two-step verification. You can disable it below.'
                              : 'For added security, enable two-step verification, which requires a PIN when registering your phone number with QikTalk again.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      if (!_is2FAEnabled) ...[
                        // Step 1
                        _StepRow(
                          number: '1',
                          title: 'Create a PIN',
                          subtitle: 'Choose a 6-digit PIN that you can remember',
                          isDark: isDark,
                        ),
                        const SizedBox(height: 20),
                        // Step 2
                        _StepRow(
                          number: '2',
                          title: 'Add a recovery email',
                          subtitle: 'Required to reset your PIN if you forget it',
                          isDark: isDark,
                        ),
                        const SizedBox(height: 32),
                        // Warning box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A2A1A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: Color(0xFFFFB800), size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFFFFB800),
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                    children: const [
                                      TextSpan(
                                        text: 'Important: ',
                                        style: TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      TextSpan(
                                        text:
                                            'If you forget your PIN and don\'t have a recovery email, you will lose access to your account. A recovery email is required.',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Enable button
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const CreatePinScreen(),
                            )).then((_) {
                              // After setup, mark as enabled and refresh from server
                              setState(() => _is2FAEnabled = true);
                              _fetch2FAStatus();
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5C3A1A),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                'Enable',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // 2FA is enabled — show status card and disable button
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A3A2A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: Color(0xFF34C759), size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Two-step verification is active. Your account has an extra layer of protection.',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF34C759),
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Disable button
                        GestureDetector(
                          onTap: _disable2FA,
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3A1A1A),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFF3B30),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Disable Two-Step Verification',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFFF3B30),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

// ── Disable 2FA confirmation dialog ──────────────────────────────────────────

class _DisableConfirmDialog extends StatelessWidget {
  final TextEditingController codeController;

  const _DisableConfirmDialog({required this.codeController});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color dialogBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFAF5F0);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1A1008);
    final Color textSecondary = isDark ? const Color(0xFFA3A3A3) : const Color(0xFF6B6B6B);
    final Color cancelBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE8DDD0);
    final Color borderColor = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFD9CFC4);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: dialogBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context, false),
                child: Icon(Icons.close, color: textSecondary, size: 26),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF3A1A1A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_open_rounded,
                color: Color(0xFFFF3B30),
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Disable Two-Step Verification',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Enter your current 2FA PIN to confirm.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: GoogleFonts.poppins(
                color: textPrimary,
                fontSize: 18,
                letterSpacing: 4,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                counterText: '',
                hintText: '000000',
                hintStyle: GoogleFonts.poppins(
                  color: textSecondary.withOpacity(0.5),
                  fontSize: 18,
                  letterSpacing: 4,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: cancelBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          'Disable',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final bool isDark;

  const _StepRow({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFF5C3A1A),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
