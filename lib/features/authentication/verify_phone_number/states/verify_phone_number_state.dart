class VerifyPhoneState {
  final bool isLoading;
  final bool isButtonEnabled;
  final String phone;
  final String otp;
  final String message;

  const VerifyPhoneState({
    required this.isLoading,
    required this.isButtonEnabled,
    required this.phone,
    required this.otp,
    required this.message,
  });

  VerifyPhoneState copyWith({
    bool? isLoading,
    bool? isButtonEnabled,
    String? phone,
    String? otp,
    String? message,
  }) {
    return VerifyPhoneState(
      isLoading: isLoading ?? this.isLoading,
      isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
      phone: phone ?? this.phone,
      otp: otp ?? this.otp,
      message: message ?? this.message,
    );
  }
}

