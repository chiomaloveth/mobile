import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/settings/account/screens/two_step_verification/two_step_intro_screen.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/services/biometric_auth_service.dart';
import 'change_password_screen.dart';
import 'trusted_devices_screen.dart';
import 'security_alerts_screen.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  bool _twoFactorEnabled = false;
  bool _isLoadingTwoFactor = true;
  bool _isTogglingTwoFactor = false;

  @override
  void initState() {
    super.initState();
    _fetchTwoFactorStatus();
  }

  Future<void> _fetchTwoFactorStatus() async {
    try {
      final token = await SaveValues().getString(AppPreferenceHelper.AUTH_TOKEN);
      final response = await http.get(
        Uri.parse(ApiStrings.twoFaStatus),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        // Response: { "success": true, "data": { "enabled": true, ... } }
        final data = body['data'] as Map<String, dynamic>? ?? {};
        final enabled = data['enabled'] as bool? ?? false;
        setState(() {
          _twoFactorEnabled = enabled;
          _isLoadingTwoFactor = false;
        });
      } else {
        setState(() => _isLoadingTwoFactor = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingTwoFactor = false);
    }
  }

  Future<void> _onTwoFactorToggle(bool val) async {
    if (_isTogglingTwoFactor) return;

    if (val) {
      // Toggle ON → go directly to PIN setup flow
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const TwoStepIntroScreen()),
      );
      // Refresh status after returning — if setup completed, toggle will be ON
      await _fetchTwoFactorStatus();
    } else {
      // Toggle OFF → ask for current PIN to confirm disable
      final codeController = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        barrierColor: Colors.black.withOpacity(0.75),
        builder: (ctx) {
          final bool isDark = Theme.of(ctx).brightness == Brightness.dark;
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE0D8D0),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3A1A1A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_open_rounded,
                        color: Color(0xFFFF3B30), size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Disable Two-Step Verification',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your current 6-digit PIN to confirm.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 22,
                      letterSpacing: 6,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '000000',
                      hintStyle: GoogleFonts.poppins(
                        color: isDark ? Colors.white24 : Colors.black26,
                        fontSize: 22,
                        letterSpacing: 6,
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx, false),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text('Cancel',
                                  style: GoogleFonts.poppins(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx, true),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF3B30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text('Disable',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  )),
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
        },
      );
      if (confirmed != true || !mounted) return;
      final code = codeController.text.trim();
      if (code.isEmpty) return;
      await _disableTwoFactor(code);
    }
  }

  Future<void> _disableTwoFactor(String pin) async {
    setState(() => _isTogglingTwoFactor = true);
    try {
      final token = await SaveValues().getString(AppPreferenceHelper.AUTH_TOKEN);
      // POST /api/v1/auth/security/two-factor/disable — body: { "pin": "123456" }
      final response = await http.post(
        Uri.parse(ApiStrings.twoFaDisable),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'pin': pin}),
      );
      debugPrint('2FA disable ${response.statusCode}: ${response.body}');
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() => _twoFactorEnabled = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Two-step verification disabled.'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        final body = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message'] ?? 'Failed to disable 2FA')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTogglingTwoFactor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    final biometricState = ref.watch(biometricAuthProvider);
    final bool biometricsEnabled = biometricState.isEnabled;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [HexColor("#171516"), HexColor("#3A1D07")]
                  : [const Color(0xFFF5EEE4), const Color(0xFFFAF5F0)],
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : AppTheme.textPrimary(isDark)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Security",
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildSectionHeader("AUTHENTICATION"),
            _buildTwoFactorItem(isDark),
            _buildSwitchItem(
              icon: Icons.visibility_outlined,
              title: "Face ID / Touch ID",
              subtitle: "Use biometrics to unlock app",
              value: biometricsEnabled,
              onChanged: (val) async {
                if (val) {
                  await ref
                      .read(biometricAuthProvider.notifier)
                      .enableBiometric();
                } else {
                  await ref
                      .read(biometricAuthProvider.notifier)
                      .disableBiometric();
                }
              },
            ),
            _buildNavItem(
              icon: Icons.key_outlined,
              title: "Change password",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            _buildSectionHeader("DEVICE MANAGEMENT"),
            _buildNavItem(
              icon: Icons.devices_outlined,
              title: "Trusted devices",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrustedDevicesScreen(),
                  ),
                );
              },
            ),
            _buildNavItem(
              icon: Icons.history_outlined,
              title: "Login activity",
              subtitle: "Recent login attempts",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SecurityAlertsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            // Protected / Not Protected Box
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _twoFactorEnabled
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _twoFactorEnabled
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _twoFactorEnabled
                        ? Icons.verified_user_outlined
                        : Icons.shield_outlined,
                    color:
                        _twoFactorEnabled ? Colors.green : Colors.orange,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _twoFactorEnabled
                              ? "Account Protected"
                              : "Account Not Fully Protected",
                          style: GoogleFonts.poppins(
                            color: _twoFactorEnabled
                                ? Colors.green
                                : Colors.orange,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _twoFactorEnabled
                              ? "Your account is secured with two-step verification. You'll need your PIN to sign in."
                              : "Enable two-step verification to add an extra layer of security to your account.",
                          style: GoogleFonts.poppins(
                            color: _twoFactorEnabled
                                ? Colors.green.withValues(alpha: 0.8)
                                : Colors.orange.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTwoFactorItem(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined,
              color: isDark ? Colors.white60 : const Color(0xFF6B5A4A),
              size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Two-step verification",
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary(isDark),
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Extra security for your account",
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary(isDark),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (_isLoadingTwoFactor || _isTogglingTwoFactor)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Switch(
              value: _twoFactorEnabled,
              onChanged: _onTwoFactorToggle,
              activeThumbColor: Colors.white,
              activeTrackColor: Colors.green,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor:
                  isDark ? Colors.white10 : Colors.black12,
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: isDark ? Colors.white38 : const Color(0xFF9E8E7E),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon,
              color: isDark ? Colors.white60 : const Color(0xFF6B5A4A),
              size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary(isDark),
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary(isDark),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.green,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: isDark ? Colors.white10 : Colors.black12,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon,
                    color:
                        isDark ? Colors.white60 : const Color(0xFF6B5A4A),
                    size: 20),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: AppTheme.textPrimary(isDark),
                          fontSize: 14,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary(isDark),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDark
                      ? Colors.white24
                      : const Color(0xFFCFC4B5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
