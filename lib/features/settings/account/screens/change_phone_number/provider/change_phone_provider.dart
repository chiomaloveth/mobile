import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:country_picker/country_picker.dart';
import 'package:qik_talk/features/authentication/provider/user_provider.dart';
import 'package:qik_talk/features/settings/account/screens/change_phone_number/services/change_phone_number_services.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

enum ChangePhoneStep { enterPhone, enterOtp, success }

class ChangePhoneState {
  final ChangePhoneStep currentStep;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final String? tempPhoneNumber;
  final Country country;

  ChangePhoneState({
    this.currentStep = ChangePhoneStep.enterPhone,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.tempPhoneNumber,
    required this.country,
  });

  ChangePhoneState copyWith({
    ChangePhoneStep? currentStep,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    String? tempPhoneNumber,
    Country? country,
  }) {
    return ChangePhoneState(
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      tempPhoneNumber: tempPhoneNumber ?? this.tempPhoneNumber,
      country: country ?? this.country,
    );
  }
}

class ChangePhoneNotifier extends StateNotifier<ChangePhoneState> {
  final ChangePhoneNumberServices _services;
  final Ref _ref;

  ChangePhoneNotifier(this._services, this._ref)
      : super(ChangePhoneState(
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
        ));

  void changeCountry(Country country) {
    state = state.copyWith(country: country);
  }

  Future<void> requestOtp(String phoneNumber) async {
    state = state.copyWith(
        isLoading: true, errorMessage: null, successMessage: null);
    try {
      String cleanedPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '').trim();
      
      // If it starts with '+', keep it as is
      if (cleanedPhone.startsWith('+')) {
        // already fully formatted
      } else {
        // If it starts with the selected country code, prepend '+' and keep the rest
        if (cleanedPhone.startsWith(state.country.phoneCode)) {
          cleanedPhone = '+$cleanedPhone';
        } else {
          // If they typed a leading zero, e.g. 07061195314, strip it first
          if (cleanedPhone.startsWith('0')) {
            cleanedPhone = cleanedPhone.substring(1);
          }
          cleanedPhone = '+${state.country.phoneCode}$cleanedPhone';
        }
      }

      final formattedPhone = cleanedPhone;

      final msg = await _services.requestPhoneNumberChange(
          phoneNumber: formattedPhone);
      state = state.copyWith(
        isLoading: false,
        currentStep: ChangePhoneStep.enterOtp,
        tempPhoneNumber: formattedPhone,
        successMessage: msg,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      );
    }
  }

  Future<void> verifyOtp(String otp) async {
    state = state.copyWith(
        isLoading: true, errorMessage: null, successMessage: null);
    try {
      final msg = await _services.confirmPhoneNumberChange(otp: otp);

      // Persist the new phone number locally
      if (state.tempPhoneNumber != null) {
        final saveValues = SaveValues();
        await saveValues.saveString(
            AppPreferenceHelper.PHONE_NUMBER, state.tempPhoneNumber!);
        // Refresh user profile in memory
        await _ref.read(userProfileProvider.notifier).loadUser();
      }

      state = state.copyWith(
        isLoading: false,
        currentStep: ChangePhoneStep.success,
        successMessage: msg,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      );
    }
  }

  void goBackToPhoneInput() {
    state = state.copyWith(
        currentStep: ChangePhoneStep.enterPhone, errorMessage: null);
  }

  void reset() {
    state = ChangePhoneState(
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
    );
  }
}

final changePhoneServicesProvider = Provider<ChangePhoneNumberServices>((ref) {
  return ChangePhoneNumberServices();
});

final changePhoneProvider =
    StateNotifierProvider<ChangePhoneNotifier, ChangePhoneState>((ref) {
  final services = ref.watch(changePhoneServicesProvider);
  return ChangePhoneNotifier(services, ref);
});
