import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../utilities/services/app_pref_helper.dart';
import '../../../../utilities/database/save_values.dart';
import '../../../../utilities/constants/app_strings/api_strings.dart';
import '../../../../utilities/bottom_nav/screen/custom_bottom_nav.dart';
import '../state/login_state.dart';
import 'package:qik_talk/features/notifications/services/notification_service.dart';
import 'package:qik_talk/features/authentication/two_fa_pin/screens/two_fa_pin_screen.dart';

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(),
);

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier() : super(const LoginState());

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final SaveValues _saveValues = SaveValues();

  /// ---------------- UI STATE ----------------
  void togglePasswordVisibility() {
    state = state.copyWith(passwordVisible: !state.passwordVisible);
  }

  void toggleRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }

  void validateForm(GlobalKey<FormState> formKey) {
    state = state.copyWith(
      isButtonEnabled: formKey.currentState?.validate() ?? false,
    );
  }

  /// ---------------- LOGIN ----------------
  Future<void> login(BuildContext context) async {
    if (!state.isButtonEnabled) return;

    state = state.copyWith(isLoading: true);

    try {
      print('POST: ${ApiStrings.login}');
      final response = await http.post(
        Uri.parse(ApiStrings.login),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      state = state.copyWith(isLoading: false);

      print("request: " + response.toString());
      print(response.statusCode);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('Response Body: ${response.body}');

        // ── Check if 2FA is required ──────────────────────────────────────
        final bool requires2FA = data['requires2FA'] == true;
        final String? tempToken = data['tempToken'] as String?;

        if (requires2FA && tempToken != null) {
          // Save temp token so TwoFaPinScreen can use it
          await _saveValues.saveString(AppPreferenceHelper.TEMP_TOKEN, tempToken);

          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const TwoFaPinScreen()),
            );
          }
          return;
        }

        // ── Normal login (no 2FA) ─────────────────────────────────────────
        final token = data['token'];
        final userId = data['_id'];
        final bool hasPassword = data['hasPassword'] ?? false;

        final String username = data['username'] ?? '';
        final String email = data['email'] ?? '';
        final String phone = data['phone'] ?? '';
        final String profilePicture = data['profilePicture'] ?? '';

        await _saveValues.saveString(AppPreferenceHelper.AUTH_TOKEN, token);
        await _saveValues.saveString(AppPreferenceHelper.ID, userId);
        await _saveValues.saveBool(AppPreferenceHelper.HAS_PASSWORD, hasPassword);
        await _saveValues.saveString(AppPreferenceHelper.USER_NAME, username);
        await _saveValues.saveString(AppPreferenceHelper.EMAIL_ADDRESS, email);
        await _saveValues.saveString(AppPreferenceHelper.PHONE_NUMBER, phone);
        await _saveValues.saveString(AppPreferenceHelper.PROFILE_IMAGE, profilePicture);

        // Register FCM token with backend after successful login
        await _registerFCMToken();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login successful")),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => CustomBottomNav()),
          );
        }
      } else {
        print('Response Body: ${response.body}');
        _showError(context, data['message'] ?? 'Login failed');
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
      _showError(context, "Network error. Please try again.");
    }
  }

  // Method to register FCM token with backend
  Future<void> _registerFCMToken() async {
    try {
      print('🔥 Starting FCM token registration...');

      final notificationService = NotificationService();
      final success = await notificationService.uploadTokenToBackend();

      if (success) {
        print('✅ FCM token registered successfully');
      } else {
        print('⚠️ FCM token registration failed (non-blocking)');
      }
    } catch (e) {
      print('❌ Error registering FCM token: $e');
    }
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
