import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/authentication/verify_phone_number/states/verify_phone_number_state.dart';

import '../../../../utilities/services/app_pref_helper.dart';
import '../../../../utilities/database/save_values.dart';
import '../../../../utilities/constants/app_strings/api_strings.dart';
import '../../../settings/account/screens/add_profile_info/screens/add_profile_info_screen.dart';

final verifyPhoneProvider =
    StateNotifierProvider<VerifyPhoneNotifier, VerifyPhoneState>(
      (ref) => VerifyPhoneNotifier(),
    );

class VerifyPhoneNotifier extends StateNotifier<VerifyPhoneState> {
  VerifyPhoneNotifier()
    : super(
        const VerifyPhoneState(
          isLoading: false,
          isButtonEnabled: false,
          phone: '',
          otp: '',
          message: '',
        ),
      ) {
    loadPhone();
  }

  final SaveValues _saveValues = SaveValues();

  /// -------- LOAD PHONE ----------
  Future<void> loadPhone() async {
    final storedPhone =
        await _saveValues.getString(AppPreferenceHelper.PHONE_NUMBER) ?? '';
    state = state.copyWith(phone: storedPhone);
  }

  /// -------- UPDATE OTP ----------
  void updateOtp(String value) {
    state = state.copyWith(otp: value, isButtonEnabled: value.length == 6);
  }

  /// -------- VERIFY PHONE ----------
  Future<void> verifyPhone(BuildContext context) async {
    state = state.copyWith(isLoading: true);

    try {
      print('POST: ${ApiStrings.verifyOtp}');
      final response = await http.post(
        Uri.parse(ApiStrings.verifyOtp),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({"phone": state.phone, "otp": state.otp}),
      );

      state = state.copyWith(isLoading: false);

      print("request: " + response.toString());
      print(response.statusCode);

      if (response.statusCode == 200) {
        print('Response Body: ${response.body}');
        final data = jsonDecode(response.body)['data'];

        final token = data['token'];
        final message = data['message'];
        final bool hasPassword = data['user']['hasPassword'];

        await _saveValues.saveString(AppPreferenceHelper.AUTH_TOKEN, token);
        await _saveValues.saveBool(
          AppPreferenceHelper.HAS_PASSWORD,
          hasPassword,
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProfileInfoScreen()),
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
}
