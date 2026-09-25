import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qik_talk/features/authentication/verify_otp/screens/verify_otp_screen.dart';
import '../../../../utilities/services/app_pref_helper.dart';
import '../../../../utilities/database/save_values.dart';
import '../../../../utilities/constants/app_strings/api_strings.dart';
import 'package:http/http.dart' as http;

import '../state/forget_password_state.dart';

final forgetPasswordProvider =
    StateNotifierProvider<ForgetPasswordNotifier, ForgetPasswordState>(
      (ref) => ForgetPasswordNotifier(),
    );

class ForgetPasswordNotifier extends StateNotifier<ForgetPasswordState> {
  ForgetPasswordNotifier()
    : super(
        const ForgetPasswordState(
          isLoading: false,
          isButtonEnabled: false,
          email: '',
        ),
      );

  final SaveValues _saveValues = SaveValues();
  final emailController = TextEditingController();

  /// ---------------- VALIDATE FORM ----------------
  void validateForm(GlobalKey<FormState> formKey) {
    state = state.copyWith(
      isButtonEnabled: formKey.currentState?.validate() ?? false,
    );
  }

  /// ---------------- REQUEST OTP ----------------
  Future<void> forgetPassword(BuildContext context) async {
    if (!state.isButtonEnabled) return;

    state = state.copyWith(isLoading: true);

    try {
      final response = await http.post(
        Uri.parse(ApiStrings.forgetPassword),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({"email": emailController.text.trim()}),
      );

      state = state.copyWith(isLoading: false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _showMessage(context, data['message'] ?? "OTP sent successfully");
        await _saveValues.saveString(
          AppPreferenceHelper.EMAIL_ADDRESS,
          emailController.text.trim(),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VerifyOtpScreen()),
        );
      } else {
        final data = jsonDecode(response.body);
        _showMessage(
          context,
          data['message'] ?? "Unknown error occurred. Try again.",
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      _showMessage(context, "Network error occurred. Please try again.");
    }
  }

  void _showMessage(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
