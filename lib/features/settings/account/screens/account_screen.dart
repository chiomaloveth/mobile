import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/authentication/login/screens/login_screen.dart';
import 'package:qik_talk/features/authentication/login/screens/login_screen.dart';
import 'package:qik_talk/features/settings/account/screens/change_phone_number/screens/change_phone_number_screen.dart';
import 'package:qik_talk/features/settings/account/screens/privacy_screens/provider/privacy_settings_provider.dart';
import 'package:qik_talk/features/settings/general/components/settings_option_card.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_icons.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_clear_service.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/services/biometric_auth_service.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';

import '../../../authentication/provider/user_provider.dart';
import '../../theme/provider/theme_provider.dart';
import '../../../feed/presentation/state/provider/feed_provider.dart';
import 'add_profile_info/screens/edit_profile_screen.dart';
import 'change_password/change_password_screen.dart';
import 'data_and_storage/screens/data_and_storage_screen.dart';
import 'privacy_screens/privacy_screen.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _isDeletingAccount = false;
  bool _isRequestingAccountInfo = false;

  // ── Request Account Info ───────────────────────────────────────────────────
  Future<void> _requestAccountInfo() async {
    setState(() => _isRequestingAccountInfo = true);
    try {
      final token =
          await SaveValues().getString(AppPreferenceHelper.AUTH_TOKEN);
      final response = await http.post(
        Uri.parse(ApiStrings.requestAccountInfo),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Account information request sent. You will receive an email with your data.',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final body = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  body['message'] ?? 'Failed to request account info'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Network error. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRequestingAccountInfo = false);
    }
  }

  // ── Delete Account — 3-step OTP flow ──────────────────────────────────────
  Future<void> _deleteAccount() async {
    // Step 1: Warning dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.80),
      builder: (_) => const _DeleteConfirmDialog(),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeletingAccount = true);

    // Step 2: POST /account/delete/request-otp — sends OTP to user's email
    String? maskedEmail;
    try {
      final token =
          await SaveValues().getString(AppPreferenceHelper.AUTH_TOKEN);

      debugPrint('🗑️ [delete] Step 1 — request-otp: ${ApiStrings.deleteAccountRequestOtp}');

      final response = await http.post(
        Uri.parse(ApiStrings.deleteAccountRequestOtp),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('🗑️ [delete] Step 1 status: ${response.statusCode}');
      debugPrint('🗑️ [delete] Step 1 body: ${response.body}');

      setState(() => _isDeletingAccount = false);
      if (!mounted) return;

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        maskedEmail = body['data']?['maskedEmail'] as String?;
        debugPrint('🗑️ [delete] OTP sent. maskedEmail: $maskedEmail');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(body['message'] ?? 'Failed to send confirmation code'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } catch (e) {
      debugPrint('🗑️ [delete] Step 1 exception: $e');
      setState(() => _isDeletingAccount = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Network error. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Step 3: Show OTP sheet — verify OTP, get deleteToken, then confirm deletion
    debugPrint('🗑️ [delete] Showing OTP sheet. maskedEmail: $maskedEmail');

    final otpConfirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (_) => _DeleteOtpSheet(
        emailHint: maskedEmail,
        // Resend: call request-otp again
        onResend: () async {
          final token =
              await SaveValues().getString(AppPreferenceHelper.AUTH_TOKEN);
          debugPrint('🗑️ [delete] Resend OTP');
          final response = await http.post(
            Uri.parse(ApiStrings.deleteAccountRequestOtp),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );
          debugPrint('🗑️ [delete] Resend status: ${response.statusCode}');
          return response.statusCode == 200;
        },
        // onProceed: verify OTP → get deleteToken → confirm deletion
        onProceed: (otp) async {
          final token =
              await SaveValues().getString(AppPreferenceHelper.AUTH_TOKEN);

          // Step 2: POST /account/delete/verify-otp
          debugPrint('🗑️ [delete] Step 2 — verify-otp');
          final verifyResponse = await http.post(
            Uri.parse(ApiStrings.deleteAccountVerifyOtp),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'otp': otp}),
          );

          debugPrint('🗑️ [delete] Step 2 status: ${verifyResponse.statusCode}');
          debugPrint('🗑️ [delete] Step 2 body: ${verifyResponse.body}');

          final verifyBody = jsonDecode(verifyResponse.body);

          if (verifyResponse.statusCode != 200) {
            throw Exception(verifyBody['message'] ?? 'Invalid or expired code.');
          }

          final deleteToken = verifyBody['data']?['deleteToken'] as String?;
          if (deleteToken == null || deleteToken.isEmpty) {
            throw Exception('Failed to get delete token. Please try again.');
          }

          // Step 3: DELETE /account/delete/confirm
          debugPrint('🗑️ [delete] Step 3 — confirm deletion');
          final confirmResponse = await http.delete(
            Uri.parse(ApiStrings.deleteAccountConfirm),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'deleteToken': deleteToken}),
          );

          debugPrint('🗑️ [delete] Step 3 status: ${confirmResponse.statusCode}');
          debugPrint('🗑️ [delete] Step 3 body: ${confirmResponse.body}');

          final confirmBody = jsonDecode(confirmResponse.body);

          if (confirmResponse.statusCode == 401) {
            // deleteToken expired — send user back to Step 1
            throw Exception('Session expired. Please request a new code.');
          }

          if (confirmResponse.statusCode != 200) {
            throw Exception(confirmBody['message'] ?? 'Failed to delete account.');
          }

          // ✅ Success — wipe ALL local data and disconnect
          GlobalSocketService().disconnect();
          ref.read(biometricAuthProvider.notifier).logout();
          await AppClearService.clearAll();
          ref.invalidate(feedProvider);
          ref.invalidate(userProfileProvider);
          ref.invalidate(privacySettingsProvider);
          debugPrint('🗑️ [delete] ✅ Account deleted, all data cleared');
          return true;
        },
      ),
    );

    if (otpConfirmed != true || !mounted) return;

    // Step 4: Success overlay then navigate to login
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.88),
      barrierDismissible: false,
      builder: (_) => const _AccountDeletedOverlay(),
    );

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LogInScreen()),
        (route) => false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    ref.read(userProfileProvider.notifier).loadUser();
    Future.microtask(() async {
      await ref.read(feedProvider.notifier).loadUserInfo(silent: true);
      if (mounted) {
        final info = ref.read(feedProvider).userInfo?.data;
        if (info != null) {
          final preservedPicture =
              ref.read(userProfileProvider).profilePicture;
          await ref
              .read(userProfileProvider.notifier)
              .updateFromUserInfo(
                username: info.username ?? '',
                about: info.about,
                fullName: info.fullName ?? '',
                profilePicture: preservedPicture.isNotEmpty
                    ? preservedPicture
                    : (info.profilePicture ?? ''),
              );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + 10;
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);
    final user = ref.watch(userProfileProvider);
    final feedState = ref.watch(feedProvider);
    final about = feedState.userInfo?.data.about ?? user.about;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : Colors.white,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : AppColors.lightNavBar,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: isDark
                ? HexColor("#3A1D07")
                : AppTheme.scaffoldBg(isDark),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                image: isDark
                    ? const DecorationImage(
                        image:
                            AssetImage("images/app_bar_gredient.png"),
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
                            color: isDark
                                ? Colors.white
                                : AppTheme.textPrimary(isDark),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: topPadding, left: 10.0),
                        child: Text(
                          "Account",
                          style: GoogleFonts.poppins(
                            color: isDark
                                ? Colors.white
                                : AppTheme.textPrimary(isDark),
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile row ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => EditProfileScreen()),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 16.0, top: 10.0),
                        child: CircleAvatar(
                          key: ValueKey(user.profilePictureUrl),
                          radius: 30.0,
                          backgroundImage: user.profilePicture.isNotEmpty
                              ? NetworkImage(user.profilePictureUrl)
                                  as ImageProvider
                              : const AssetImage("images/gal.png"),
                        ),
                      ),
                      const SizedBox(width: 15.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                user.username.isNotEmpty
                                    ? user.username
                                    : "User",
                                style: GoogleFonts.poppins(
                                  color: isDark ? Colors.white : null,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            Text(
                              about.isNotEmpty
                                  ? about
                                  : "Hey there! I am using QikTalk.",
                              style: GoogleFonts.poppins(
                                color: isDark
                                    ? Colors.white
                                    : Colors.grey.withOpacity(0.8),
                                fontSize: 14.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              _divider(isDark),
              SettingsOptionCard(
                title: "Privacy",
                value: "Last seen, profile picture, about",
                onClick: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PrivacyScreen()),
                ),
                icon: AppIcons.privacyIcon,
                isDark: isDark,
              ),
              _divider(isDark),
              SettingsOptionCard(
                title: "Change Password",
                value: "",
                onClick: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen()),
                ),
                icon: AppIcons.passwordIcon,
                isDark: isDark,
              ),
              _divider(isDark),
              SettingsOptionCard(
                title: "Data and Storage",
                value: "Network Usage, Auto Download",
                onClick: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const DataAndStorageScreen()),
                ),
                icon: AppIcons.databaseIcon,
                isDark: isDark,
              ),
              _divider(isDark),
              SettingsOptionCard(
                title: "Change Number",
                value: "",
                onClick: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => ChangePhoneNumberScreen()),
                ),
                icon: "",
                isDark: isDark,
              ),
              _divider(isDark),
              SettingsOptionCard(
                title: "Request Account Info",
                value:
                    _isRequestingAccountInfo ? "Processing..." : "",
                onClick: _isRequestingAccountInfo
                    ? () {}
                    : _requestAccountInfo,
                icon: "",
                isDark: isDark,
              ),
              _divider(isDark),

              // ── Delete My Account ──────────────────────────────────
              GestureDetector(
                onTap: _isDeletingAccount ? null : _deleteAccount,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: _isDeletingAccount
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.red, strokeWidth: 2),
                            )
                          : Image(
                              image: AssetImage(AppIcons.deleteIcon),
                              width: 30.0,
                              height: 30.0,
                            ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 10.0, top: 20.0),
                      child: Text(
                        "Delete My Account",
                        style: GoogleFonts.poppins(
                          color: HexColor("#FF383C"),
                          fontSize: 17.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              _divider(isDark),
              const SizedBox(height: 50.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider(bool isDark) => Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(top: 20.0),
        height: 2,
        color: isDark ? Colors.black : Colors.grey.withOpacity(0.2),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
const _kGradColors = [
  Color(0xFFE91E63),
  Color(0xFF9C27B0),
  Color(0xFF2196F3),
  Color(0xFF00BCD4),
];

class _GradientBorderBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color innerBg;

  const _GradientBorderBtn({
    required this.label,
    required this.onTap,
    required this.innerBg,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: _kGradColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: innerBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white),
                    ),
                  )
                : Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Modal 1: Delete Confirmation Dialog ───────────────────────────────────────
class _DeleteConfirmDialog extends StatelessWidget {
  const _DeleteConfirmDialog();

  @override
  Widget build(BuildContext context) {
    const Color dialogBg = Color(0xFF1E1E1E);
    const Color textPrimary = Colors.white;
    const Color textSecondary = Color(0xFFA3A3A3);
    const Color cancelBg = Color(0xFF2C2C2E);
    const Color borderColor = Color(0xFF3A3A3C);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: dialogBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context, false),
                child: const Icon(Icons.close,
                    color: textSecondary, size: 26),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: Color(0xFF4A1515),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFFF6B6B), size: 46),
            ),
            const SizedBox(height: 22),
            Text(
              'Delete Account',
              style: GoogleFonts.poppins(
                color: textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Are you sure you want to delete your account?\nThis action cannot be undone.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: textSecondary,
                fontSize: 15,
                height: 1.55,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 36),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: cancelBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            color: textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _GradientBorderBtn(
                    label: 'Delete',
                    innerBg: dialogBg,
                    onTap: () => Navigator.pop(context, true),
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

// ── Modal 2: OTP Sheet ─────────────────────────────────────────────────────────
class _DeleteOtpSheet extends StatefulWidget {
  final String? emailHint;
  final Future<bool> Function() onResend;
  final Future<bool> Function(String otp) onProceed;

  const _DeleteOtpSheet({
    required this.emailHint,
    required this.onResend,
    required this.onProceed,
  });

  @override
  State<_DeleteOtpSheet> createState() => _DeleteOtpSheetState();
}

class _DeleteOtpSheetState extends State<_DeleteOtpSheet> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  String _errorMsg = '';
  int _resendSeconds = 60;
  Timer? _resendTimer;

  static const Color _orange = Color(0xFFFF8C00);
  static const Color _sheetBg = Color(0xFF1A1A1C);
  static const Color _cellBg = Color(0xFF2C2C2E);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFFA3A3A3);

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _resendSeconds--;
        if (_resendSeconds <= 0) t.cancel();
      });
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();
  bool get _isComplete => _otp.length == 6;

  void _onCellChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < 6 && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      final next = digits.length < 6 ? digits.length : 5;
      _focusNodes[next].requestFocus();
      setState(() {});
      return;
    }
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _proceed() async {
    if (!_isComplete || _isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });
    try {
      final success = await widget.onProceed(_otp);
      if (!mounted) return;
      if (success) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMsg = e.toString().replaceAll('Exception:', '').trim();
        for (final c in _controllers) c.clear();
        _focusNodes[0].requestFocus();
      });
    }
  }

  Future<void> _resend() async {
    if (_resendSeconds > 0) return;
    setState(() => _errorMsg = '');
    try {
      final success = await widget.onResend();
      if (mounted) {
        if (success) {
          _startResendTimer();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification code resent to your email.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          setState(() => _errorMsg = 'Failed to resend code. Please try again.');
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMsg = 'Network error. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final maskedEmail = widget.emailHint != null
        ? _maskEmail(widget.emailHint!)
        : 'your email';

    return Container(
      decoration: const BoxDecoration(
        color: _sheetBg,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        28,
        24,
        MediaQuery.of(context).viewInsets.bottom + 56,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF48484A),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),

          Text(
            'Check Your Email',
            style: GoogleFonts.poppins(
              color: _textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'Enter the 6-digit code sent to $maskedEmail to confirm account deletion.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: _textSecondary,
              fontSize: 14,
              height: 1.55,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 36),

          // ── OTP cells — responsive layout fix ─────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final cellSize = (constraints.maxWidth - 60) / 6;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  final isFilled =
                      _controllers[i].text.isNotEmpty;
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5),
                    child: SizedBox(
                      width: cellSize,
                      height: cellSize * 1.13,
                      child: TextField(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: GoogleFonts.poppins(
                          color: _textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        cursorColor: _orange,
                        onChanged: (v) => _onCellChanged(i, v),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: _cellBg,
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(
                              color: isFilled
                                  ? _orange.withOpacity(0.6)
                                  : const Color(0xFF48484A),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: const BorderSide(
                                color: _orange, width: 2),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),

          const SizedBox(height: 20),

          if (_errorMsg.isNotEmpty) ...[
            Text(
              _errorMsg,
              style: GoogleFonts.poppins(
                  color: const Color(0xFFFF6B6B), fontSize: 13),
            ),
            const SizedBox(height: 12),
          ],

          // Resend
          GestureDetector(
            onTap: _resendSeconds == 0 ? _resend : null,
            child: Text(
              _resendSeconds > 0
                  ? 'Resend Code ($_resendSeconds s)'
                  : 'Resend Code',
              style: GoogleFonts.poppins(
                color: _resendSeconds > 0
                    ? const Color(0xFF636366)
                    : _orange,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: _GradientBorderBtn(
              label: 'Verify & Delete',
              innerBg: _sheetBg,
              isLoading: _isLoading,
              onTap:
                  _isComplete && !_isLoading ? _proceed : null,
            ),
          ),
        ],
      ),
    );
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '${name[0]}***@$domain';
    return '${name.substring(0, 2)}***@$domain';
  }
}

// ── Modal 3: Account Deleted Success Overlay ───────────────────────────────────
class _AccountDeletedOverlay extends StatelessWidget {
  const _AccountDeletedOverlay();

  @override
  Widget build(BuildContext context) {
    const Color dialogBg = Color(0xFF1E1E1E);
    const Color textPrimary = Colors.white;
    const Color textSecondary = Color(0xFFA3A3A3);
    const Color borderColor = Color(0xFF3A3A3C);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        decoration: BoxDecoration(
          color: dialogBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFE91E63).withOpacity(0.30),
                        const Color(0xFF00BCD4).withOpacity(0.18),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: _kGradColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(0xFFE91E63).withOpacity(0.40),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color:
                            const Color(0xFF00BCD4).withOpacity(0.28),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 46),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Account Deletion Scheduled',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Your account has been scheduled for deletion and will be permanently removed in 30 days.\nWe\'re sorry to see you go.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: textSecondary,
                fontSize: 14,
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: _GradientBorderBtn(
                label: 'Back to Login',
                innerBg: dialogBg,
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}