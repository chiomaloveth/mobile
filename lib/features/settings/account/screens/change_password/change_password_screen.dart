import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends ConsumerState<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final current = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _showSnack('Please fill in all fields');
      return;
    }
    if (newPass.length < 6) {
      _showSnack('New password must be at least 6 characters');
      return;
    }
    if (newPass != confirm) {
      _showSnack('New passwords do not match');
      return;
    }
    if (current == newPass) {
      _showSnack('New password must be different from current password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token =
          await SaveValues().getString(AppPreferenceHelper.AUTH_TOKEN);

      final response = await http.put(
        Uri.parse(ApiStrings.changePassword), // ✅ uses constant
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'currentPassword': current,
          'newPassword': newPass,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnack(body['message'] ?? 'Password changed successfully');
        if (mounted) Navigator.pop(context);
      } else {
        _showSnack(body['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      _showSnack('Network error. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
    final Color scaffoldBg = AppTheme.scaffoldBg(isDark);
    final Color textPrimary = AppTheme.textPrimary(isDark);
    final Color textSecondary = AppTheme.textSecondary(isDark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: scaffoldBg,
        body: Stack(
          children: [
            if (isDark)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  'images/waves.png',
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height * 0.45,
                ),
              ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 8),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back,
                          color: textPrimary, size: 24),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      'Change Password',
                      style: GoogleFonts.poppins(
                        color: textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Enter your current and new password below',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Current Password', textSecondary),
                        const SizedBox(height: 8),
                        _buildPasswordField(
                          controller: _currentPasswordController,
                          show: _showCurrent,
                          onToggle: () => setState(
                              () => _showCurrent = !_showCurrent),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 24),
                        _label('New Password', textSecondary),
                        const SizedBox(height: 8),
                        _buildPasswordField(
                          controller: _newPasswordController,
                          show: _showNew,
                          onToggle: () =>
                              setState(() => _showNew = !_showNew),
                          hint: '••••••••••••••••',
                          isDark: isDark,
                        ),
                        const SizedBox(height: 24),
                        _label('Confirm New Password', textSecondary),
                        const SizedBox(height: 8),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          show: _showConfirm,
                          onToggle: () => setState(
                              () => _showConfirm = !_showConfirm),
                          hint: '••••••••••••••••',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 40),
                    child: _buildChangeButton(isDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, Color color) {
    return Text(
      text,
      style: GoogleFonts.poppins(
          color: color, fontSize: 13, fontWeight: FontWeight.w400),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool show,
    required VoidCallback onToggle,
    String? hint,
    bool isDark = true,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.inputFill(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white24 : AppTheme.inputBorder(isDark),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.lock_outline,
              color: AppTheme.iconColorSubtle(isDark), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: !show,
              style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary(isDark), fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: GoogleFonts.poppins(
                    color: AppTheme.textHint(isDark), fontSize: 14),
              ),
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(
                show
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppTheme.iconColorSubtle(isDark),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeButton(bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (isDark)
          Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF007A).withOpacity(0.35),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: const Color(0xFFFF6600).withOpacity(0.3),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        GestureDetector(
          onTap: _changePassword,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1A1A1A)
                  : AppTheme.accent(isDark),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? const Color(0xFFFF007A)
                    : AppTheme.accent(isDark),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                      'Change Password',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}