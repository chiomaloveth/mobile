import 'package:country_picker/country_picker.dart';

class SignUpState {
  final bool isLoading;
  final bool isButtonEnabled;
  final bool rememberMe;
  final String phone;
  final Country country;

  const SignUpState({
    required this.isLoading,
    required this.isButtonEnabled,
    required this.rememberMe,
    required this.phone,
    required this.country,
  });

  SignUpState copyWith({
    bool? isLoading,
    bool? isButtonEnabled,
    bool? rememberMe,
    String? phone,
    Country? country,
  }) {
    return SignUpState(
      isLoading: isLoading ?? this.isLoading,
      isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
      rememberMe: rememberMe ?? this.rememberMe,
      phone: phone ?? this.phone,
      country: country ?? this.country,
    );
  }
}
