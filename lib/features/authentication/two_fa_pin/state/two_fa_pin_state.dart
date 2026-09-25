class TwoFaPinState {
  final String pin;
  final bool isLoading;
  final bool isButtonEnabled;
  final String? errorMessage;

  const TwoFaPinState({
    this.pin = '',
    this.isLoading = false,
    this.isButtonEnabled = false,
    this.errorMessage,
  });

  TwoFaPinState copyWith({
    String? pin,
    bool? isLoading,
    bool? isButtonEnabled,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TwoFaPinState(
      pin: pin ?? this.pin,
      isLoading: isLoading ?? this.isLoading,
      isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ResetPinState {
  final String email;
  final String otp;
  final String newPin;
  final String confirmPin;
  final bool isLoading;
  final bool isButtonEnabled;
  final String? errorMessage;
  final int step; // 1=email, 2=otp, 3=create, 4=confirm, 5=success

  const ResetPinState({
    this.email = '',
    this.otp = '',
    this.newPin = '',
    this.confirmPin = '',
    this.isLoading = false,
    this.isButtonEnabled = false,
    this.errorMessage,
    this.step = 1,
  });

  ResetPinState copyWith({
    String? email,
    String? otp,
    String? newPin,
    String? confirmPin,
    bool? isLoading,
    bool? isButtonEnabled,
    String? errorMessage,
    int? step,
    bool clearError = false,
  }) {
    return ResetPinState(
      email: email ?? this.email,
      otp: otp ?? this.otp,
      newPin: newPin ?? this.newPin,
      confirmPin: confirmPin ?? this.confirmPin,
      isLoading: isLoading ?? this.isLoading,
      isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      step: step ?? this.step,
    );
  }
}
