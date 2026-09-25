import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:country_picker/country_picker.dart';
import 'package:qik_talk/features/authentication/register/state/sign_up_state.dart';

import '../../../../utilities/services/app_pref_helper.dart';
import '../../../../utilities/database/save_values.dart';
import '../../../../utilities/constants/app_strings/api_strings.dart';
import '../../verify_phone_number/screens/verify_phone_number_screen.dart';

final signUpProvider = StateNotifierProvider<SignUpNotifier, SignUpState>(
  (ref) => SignUpNotifier(),
);

class SignUpNotifier extends StateNotifier<SignUpState> {
  SignUpNotifier()
    : super(
        SignUpState(
          isLoading: false,
          isButtonEnabled: false,
          rememberMe: false,
          phone: '',
          country: Country(
            phoneCode: '234',
            countryCode: 'NG',
            e164Sc: 0,
            geographic: true,
            level: 1,
            name: 'Nigeria',
            example: '8123456789',
            displayName: 'Nigeria (NG) [+234]',
            displayNameNoCountryCode: 'Nigeria (NG)',
            e164Key: '234-NG-0',
          ),
        ),
      ) {
    loadRememberedPhone();
  }

  final phoneController = TextEditingController();
  final SaveValues _prefs = SaveValues();

  /// Load remembered phone
  Future<void> loadRememberedPhone() async {
    final remember =
        await _prefs.getBool(AppPreferenceHelper.REMEMBER_ME) ?? false;

    if (remember) {
      final phone =
          await _prefs.getString(AppPreferenceHelper.PHONE_NUMBER) ?? '';
      phoneController.text = phone.replaceAll('+234', '');

      state = state.copyWith(rememberMe: true, phone: phoneController.text);
    }
  }

  void onPhoneChanged(String value, GlobalKey<FormState> formKey) {
    state = state.copyWith(
      phone: value,
      isButtonEnabled: formKey.currentState?.validate() ?? false,
    );
  }

  void toggleRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }

  void changeCountry(Country country) {
    state = state.copyWith(country: country);
  }

  /// Request OTP
  Future<void> requestOtp(BuildContext context) async {
    if (!state.isButtonEnabled) return;

    state = state.copyWith(isLoading: true);

    try {
      print('POST: ${ApiStrings.requestOtp}');
      final response = await http.post(
        Uri.parse(ApiStrings.requestOtp),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({
          "phone": '+${state.country.phoneCode}${phoneController.text.trim()}',
        }),
      );

      state = state.copyWith(isLoading: false);

      print("request: " + response.toString());
      print(response.statusCode);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('Response Body: ${response.body}');
        final userId = data['data']['userId'];
        final message = data['data']['message'];

        if (state.rememberMe) {
          await _prefs.saveBool(AppPreferenceHelper.REMEMBER_ME, true);
          await _prefs.saveString(
            AppPreferenceHelper.PHONE_NUMBER,
            '+${state.country.phoneCode}${phoneController.text}',
          );
        } else {
          await _prefs.clearPrefValue(AppPreferenceHelper.REMEMBER_ME);
          await _prefs.clearPrefValue(AppPreferenceHelper.PHONE_NUMBER);
        }

        await _prefs.saveString(AppPreferenceHelper.ID, userId);
        await _prefs.saveString(
          AppPreferenceHelper.PHONE_NUMBER,
          '+${state.country.phoneCode}${phoneController.text}',
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VerifyPhoneScreen()),
        );
      } else {
        print('Response Body: ${response.body}');
        _showError(context, data['message'] ?? 'Something went wrong');
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
      _showError(context, 'Network error. Try again.');
    }
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }
}
