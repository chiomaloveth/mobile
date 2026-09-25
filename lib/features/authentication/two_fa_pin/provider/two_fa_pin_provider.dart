import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/authentication/two_fa_pin/state/two_fa_pin_state.dart';
import 'package:qik_talk/utilities/bottom_nav/screen/custom_bottom_nav.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/features/notifications/services/notification_service.dart';

// ── 2FA PIN Provider (login verification) ────────────────────────────────────

class TwoFaPinNotifier extends StateNotifier<TwoFaPinState> {
  TwoFaPinNotifier() : super(const TwoFaPinState());

  final TextEditingController pinController = TextEditingController();
  final SaveValues _saveValues = SaveValues();

  void updatePin(String value) {
    state = state.copyWith(
      pin: value,
      isButtonEnabled: value.length == 6,
      clearError: true,
    );
  }

  /// POST /api/v1/auth/security/2fa/verify
  /// Body: { "pin": "123456", "tempToken": "..." }
  /// Success response: { "success": true, "token": "...", "_id": "...", ... }
  Future<void> authenticate({required BuildContext context, required String userID}) async {
    if (state.pin.length != 6) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final tempToken =
          await _saveValues.getString(AppPreferenceHelper.TEMP_TOKEN) ?? '';

      debugPrint('🔐 [2FA verify] tempToken present: ${tempToken.isNotEmpty}');
      debugPrint('🔐 [2FA verify] URL: ${ApiStrings.twoFaVerify}');

      if (tempToken.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Session expired. Please log in again.',
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Session expired. Please log in again.')),
          );
        }
        return;
      }

      final uri = Uri.parse(ApiStrings.twoFaVerify);
      debugPrint('🔐 [2FA verify] full URL: $uri');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'pin': state.pin,
          'tempToken': tempToken,
        }),
      );

      debugPrint('🔐 [2FA verify] status: ${response.statusCode}');
      debugPrint('🔐 [2FA verify] body: ${response.body}');

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Save the real auth token returned by the server
        final token = data['token'] as String? ?? '';
        if (token.isNotEmpty) {
          await _saveValues.saveString(AppPreferenceHelper.AUTH_TOKEN, token);
        }
        await _saveValues.clearPrefValue(AppPreferenceHelper.TEMP_TOKEN);

        // Save user profile fields
        final id = data['_id'] as String? ?? '';
        if (id.isNotEmpty) {
          await _saveValues.saveString(AppPreferenceHelper.ID, id);
        }
        final username = data['username'] as String? ?? '';
        if (username.isNotEmpty) {
          await _saveValues.saveString(AppPreferenceHelper.USER_NAME, username);
        }
        final email = data['email'] as String? ?? '';
        if (email.isNotEmpty) {
          await _saveValues.saveString(AppPreferenceHelper.EMAIL_ADDRESS, email);
        }
        final phone = data['phone'] as String? ?? '';
        if (phone.isNotEmpty) {
          await _saveValues.saveString(AppPreferenceHelper.PHONE_NUMBER, phone);
        }
        final profilePicture = data['profilePicture'] as String? ?? '';
        if (profilePicture.isNotEmpty) {
          await _saveValues.saveString(AppPreferenceHelper.PROFILE_IMAGE, profilePicture);
        }

        debugPrint('🔐 [2FA verify] ✅ success — token saved, navigating home');

        // Register FCM token (non-blocking)
        try {
          await NotificationService().uploadTokenToBackend();
        } catch (_) {}

        state = state.copyWith(isLoading: false);

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => CustomBottomNav()),
          );
        }
      } else {
        final msg = data['message'] as String? ??
            'Incorrect PIN. Please try again.';
        debugPrint('🔐 [2FA verify] ❌ failed: $msg');
        state = state.copyWith(isLoading: false, errorMessage: msg);
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(msg)));
        }
      }
    } catch (e, st) {
      debugPrint('🔐 [2FA verify] 💥 exception: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Network error. Please try again.',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error. Please try again.')),
        );
      }
    }
  }

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }
}

final twoFaPinProvider =
    StateNotifierProvider.autoDispose<TwoFaPinNotifier, TwoFaPinState>(
  (ref) => TwoFaPinNotifier(),
);

// ── Reset PIN Provider ────────────────────────────────────────────────────────

class ResetPinNotifier extends StateNotifier<ResetPinState> {
  ResetPinNotifier() : super(const ResetPinState());

  // emailController is kept for the UI — the email field is shown to the user
  // but the backend forgot-pin endpoint only needs the tempToken in the body.
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPinController = TextEditingController();
  final TextEditingController confirmPinController = TextEditingController();

  final SaveValues _saveValues = SaveValues();

  // ── Field update helpers ──────────────────────────────────────────────────

  void updateEmail(String value) {
    final isValid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim());
    state = state.copyWith(
      email: value,
      isButtonEnabled: isValid,
      clearError: true,
    );
  }

  void updateOtp(String value) {
    state = state.copyWith(
      otp: value,
      isButtonEnabled: value.length == 6,
      clearError: true,
    );
  }

  void updateNewPin(String value) {
    state = state.copyWith(
      newPin: value,
      isButtonEnabled: value.length == 6,
      clearError: true,
    );
  }

  void updateConfirmPin(String value) {
    state = state.copyWith(
      confirmPin: value,
      isButtonEnabled: value.length == 6,
      clearError: true,
    );
  }

  // ── Step 1: Request reset OTP ─────────────────────────────────────────────
  /// POST /api/v1/auth/2fa/forgot-pin
  /// Body: { "tempToken": "...", "email": "..." }
  /// Response: { "success": true, "message": "OTP sent successfully" }
  ///
  /// The email entered by the user is sent alongside the tempToken so the
  /// backend knows where to deliver the OTP (required when no recovery email
  /// is stored on the account, or as a fallback).
  Future<bool> sendResetEmail(BuildContext context) async {
    if (!state.isButtonEnabled) return false;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final tempToken =
          await _saveValues.getString(AppPreferenceHelper.TEMP_TOKEN) ?? '';
      final email = emailController.text.trim();

      debugPrint('📧 [forgot-pin] URL: ${ApiStrings.twoFaResetRequest}');
      debugPrint('📧 [forgot-pin] tempToken present: ${tempToken.isNotEmpty}');
      debugPrint('📧 [forgot-pin] email: $email');

      if (tempToken.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Session expired. Please log in again.',
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Session expired. Please log in again.')),
          );
        }
        return false;
      }

      // Send both tempToken and email — backend needs email to deliver OTP
      // when no recovery email is stored on the account.
      final requestBody = jsonEncode({
        'tempToken': tempToken,
        'email': email,
      });
      debugPrint('📧 [forgot-pin] request body: {"tempToken":"***","email":"$email"}');

      final response = await http.post(
        Uri.parse(ApiStrings.twoFaResetRequest),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      debugPrint('📧 [forgot-pin] status: ${response.statusCode}');
      debugPrint('📧 [forgot-pin] body: ${response.body}');

      state = state.copyWith(isLoading: false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('📧 [forgot-pin] ✅ OTP sent successfully');
        return true;
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final serverMsg = data['message'] as String? ?? '';
        debugPrint('📧 [forgot-pin] ❌ failed: $serverMsg');

        // "Could not send email" means no recovery email is stored on the account.
        final msg = serverMsg.toLowerCase().contains('could not send email') ||
                serverMsg.toLowerCase().contains('email')
            ? 'No recovery email is set up for this account. Please contact support.'
            : serverMsg.isNotEmpty
                ? serverMsg
                : 'Failed to send reset OTP.';

        state = state.copyWith(errorMessage: msg);
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(msg)));
        }
        return false;
      }
    } catch (e, st) {
      debugPrint('📧 [forgot-pin] 💥 exception: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Network error. Please try again.',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error. Please try again.')),
        );
      }
      return false;
    }
  }

  // ── Step 2: Reset PIN with OTP ────────────────────────────────────────────
  /// POST /api/v1/auth/2fa/reset-pin
  /// Body: { "tempToken": "...", "otp": "...", "newPin": "..." }
  /// Response: { "success": true, "token": "jwt_token", "user": { ... } }
  Future<bool> verifyOtpAndSetPin(BuildContext context) async {
    final newPin = newPinController.text.trim();
    final confirmPin = confirmPinController.text.trim();
    final otp = otpController.text.trim();

    if (newPin.length != 6) {
      state = state.copyWith(errorMessage: 'Please enter a new 6-digit PIN.');
      return false;
    }
    if (newPin != confirmPin) {
      state = state.copyWith(errorMessage: 'PINs do not match.');
      return false;
    }
    if (otp.length != 6) {
      state = state.copyWith(errorMessage: 'Please enter the 6-digit OTP.');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final tempToken =
          await _saveValues.getString(AppPreferenceHelper.TEMP_TOKEN) ?? '';

      debugPrint('🔑 [reset-pin] URL: ${ApiStrings.twoFaResetConfirm}');
      debugPrint('🔑 [reset-pin] tempToken present: ${tempToken.isNotEmpty}');
      debugPrint('🔑 [reset-pin] otp: $otp  newPin: ***');

      final requestBody = jsonEncode({
        'tempToken': tempToken,
        'otp': otp,
        'newPin': newPin,
      });
      debugPrint('🔑 [reset-pin] request body (pin redacted): '
          '{"tempToken":"${tempToken.isNotEmpty ? "***" : "EMPTY"}","otp":"$otp","newPin":"***"}');

      final response = await http.post(
        Uri.parse(ApiStrings.twoFaResetConfirm),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      debugPrint('🔑 [reset-pin] status: ${response.statusCode}');
      debugPrint('🔑 [reset-pin] body: ${response.body}');

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      state = state.copyWith(isLoading: false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Response: { "success": true, "token": "jwt_token", "user": { ... } }
        final token = data['token'] as String? ?? '';
        final user = data['user'] as Map<String, dynamic>? ?? {};

        debugPrint('🔑 [reset-pin] ✅ success — token present: ${token.isNotEmpty}');

        if (token.isNotEmpty) {
          await _saveValues.saveString(AppPreferenceHelper.AUTH_TOKEN, token);
          await _saveValues.clearPrefValue(AppPreferenceHelper.TEMP_TOKEN);

          final userId = user['_id'] as String? ?? user['id'] as String? ?? '';
          if (userId.isNotEmpty) {
            await _saveValues.saveString(AppPreferenceHelper.ID, userId);
          }
          final username = user['username'] as String? ?? '';
          if (username.isNotEmpty) {
            await _saveValues.saveString(AppPreferenceHelper.USER_NAME, username);
          }
          final email = user['email'] as String? ?? '';
          if (email.isNotEmpty) {
            await _saveValues.saveString(AppPreferenceHelper.EMAIL_ADDRESS, email);
          }
          final phone = user['phone'] as String? ?? '';
          if (phone.isNotEmpty) {
            await _saveValues.saveString(AppPreferenceHelper.PHONE_NUMBER, phone);
          }
          final profilePicture = user['profilePicture'] as String? ?? '';
          if (profilePicture.isNotEmpty) {
            await _saveValues.saveString(
                AppPreferenceHelper.PROFILE_IMAGE, profilePicture);
          }
        }
        return true;
      } else {
        final msg =
            data['message'] as String? ?? 'Code is incorrect or expired.';
        debugPrint('🔑 [reset-pin] ❌ failed: $msg');
        state = state.copyWith(errorMessage: msg);
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(msg)));
        }
        return false;
      }
    } catch (e, st) {
      debugPrint('🔑 [reset-pin] 💥 exception: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Network error. Please try again.',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error. Please try again.')),
        );
      }
      return false;
    }
  }

  // ── Resend OTP ────────────────────────────────────────────────────────────
  Future<void> resendOtp(BuildContext context) async {
    debugPrint('📧 [resend-otp] triggered');
    await sendResetEmail(context);
  }

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    newPinController.dispose();
    confirmPinController.dispose();
    super.dispose();
  }
}

final resetPinProvider =
    StateNotifierProvider.autoDispose<ResetPinNotifier, ResetPinState>(
  (ref) => ResetPinNotifier(),
);
