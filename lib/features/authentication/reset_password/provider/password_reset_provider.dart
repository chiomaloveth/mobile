import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/authentication/reset_password/components/success_password_reset_dialog.dart';

import '../../../../utilities/services/app_pref_helper.dart';
import '../../../../utilities/database/save_values.dart';
import '../../../../utilities/constants/app_strings/api_strings.dart';
import '../state/password_reset_state.dart';

final passwordResetProvider =
    StateNotifierProvider<PasswordResetNotifier, PasswordResetState>(
      (ref) => PasswordResetNotifier(),
    );

class PasswordResetNotifier extends StateNotifier<PasswordResetState> {
  PasswordResetNotifier() : super(const PasswordResetState()) {}

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final SaveValues _saveValues = SaveValues();

  /// ---------------- TOGGLE PASSWORD VISIBILITY ----------------
  void togglePasswordVisibility() {
    state = state.copyWith(passwordVisible: !state.passwordVisible);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      confirmPasswordVisible: !state.confirmPasswordVisible,
    );
  }

  /// ---------------- VALIDATE FORM ----------------
  void validateForm(GlobalKey<FormState> formKey) {
    state = state.copyWith(
      isButtonEnabled: formKey.currentState?.validate() ?? false,
    );
  }

  /// ---------------- SUBMIT NEW PASSWORD ----------------
  Future<void> submitPassword(BuildContext context) async {
    if (!state.isButtonEnabled) return;

    final resetToken = await _saveValues.getString(
      AppPreferenceHelper.SELECTED_TOKEN,
    );

    state = state.copyWith(isLoading: true, message: '');

    try {
      print('POST: ${ApiStrings.passwordReset}');
      final response = await http.post(
        Uri.parse(ApiStrings.passwordReset),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({
          "resetToken": resetToken,
          "newPassword": passwordController.text.trim(),
        }),
      );

      state = state.copyWith(isLoading: false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? 'Password changed successfully';

        showDialog(
          context: context,
          barrierDismissible: false, // optional but recommended for forms
          builder: (context) => SuccessPasswordResetDialog(),
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      } else {
        print('Response Body: ${response.body}');
        final error = jsonDecode(response.body)['message'] ?? 'Error occurred';
        _showError(context, error);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
      _showError(context, 'Network error. Please try again.');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
