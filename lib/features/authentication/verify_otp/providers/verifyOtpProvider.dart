import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/authentication/reset_password/screens/password_reset_screen.dart';
import 'package:qik_talk/features/authentication/verify_otp/state/verify_otp_state.dart';
import 'package:qik_talk/features/authentication/verify_phone_number/states/verify_phone_number_state.dart';

import '../../../../utilities/services/app_pref_helper.dart';
import '../../../../utilities/database/save_values.dart';
import '../../../../utilities/constants/app_strings/api_strings.dart';

final verifyOtpProvider =
    StateNotifierProvider<VerifyOtpNotifier, VerifyOtpState>(
      (ref) => VerifyOtpNotifier(),
    );

class VerifyOtpNotifier extends StateNotifier<VerifyOtpState> {
  VerifyOtpNotifier()
    : super(
        const VerifyOtpState(
          isLoading: false,
          isButtonEnabled: false,
          email: '',
          otp: '',
          message: '',
          secondsRemaining: 60, // ⏱ start from 60s
          canResend: false,
        ),
      ) {
    _startTimer();
    loadEmail();
  }

  final SaveValues _saveValues = SaveValues();

  /// -------- LOAD PHONE ----------
  Future<void> loadEmail() async {
    final storedEmail =
        await _saveValues.getString(AppPreferenceHelper.EMAIL_ADDRESS) ?? '';
    state = state.copyWith(email: storedEmail);
  }

  /// -------- UPDATE OTP ----------
  void updateOtp(String value) {
    state = state.copyWith(otp: value, isButtonEnabled: value.length == 6);
  }

  /// -------- VERIFY PHONE ----------
  Future<void> verifyEmailOtp(BuildContext context) async {
    state = state.copyWith(isLoading: true);

    try {
      print('POST: ${ApiStrings.verifyEmailOtp}');
      final response = await http.post(
        Uri.parse(ApiStrings.verifyEmailOtp),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({"email": state.email, "otp": state.otp}),
      );

      state = state.copyWith(isLoading: false);

      print("request: " + response.toString());
      print(response.statusCode);

      if (response.statusCode == 200) {
        print('Response Body: ${response.body}');
        // Response: { "success": true, "message": "...", "resetToken": "JWT..." }
        // resetToken is at the ROOT level, not nested under data
        final body = jsonDecode(response.body);

        final resetToken = body['resetToken'] as String? ?? '';
        final message = body['message'] as String? ?? 'Code verified successfully';

        if (resetToken.isEmpty) {
          _showError(context, 'Verification failed. Please try again.');
          return;
        }

        await _saveValues.saveString(
          AppPreferenceHelper.SELECTED_TOKEN,
          resetToken,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PasswordResetScreen()),
        );
      } else {
        print('Response Body: ${response.body}');
        final error = jsonDecode(response.body)['message'] ?? 'Invalid OTP';
        _showError(context, error);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
      _showError(context, 'Network error. Please try again.');
    }
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Timer? _timer;

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondsRemaining == 0) {
        timer.cancel();
        state = state.copyWith(canResend: true);
      } else {
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      }
    });
  }

  void resendCode() {
    if (!state.canResend) return;

    state = state.copyWith(secondsRemaining: 60, canResend: false);
    _startTimer();

    // Call forgot-password again to resend the OTP
    http.post(
      Uri.parse(ApiStrings.forgetPassword),
      headers: {"Content-type": "application/json"},
      body: jsonEncode({"email": state.email}),
    ).then((response) {
      print('Resend OTP ${response.statusCode}: ${response.body}');
    }).catchError((e) {
      print('Resend OTP error: $e');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
