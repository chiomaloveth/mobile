class VerifyOtpState {
  final bool isLoading;
  final bool isButtonEnabled;
  final String email;
  final String otp;
  final String message;
  final int secondsRemaining;
  final bool canResend;

  const VerifyOtpState({
    required this.isLoading,
    required this.isButtonEnabled,
    required this.email,
    required this.otp,
    required this.message,
    required this.secondsRemaining,
    required this.canResend,
  });

  VerifyOtpState copyWith({
    bool? isLoading,
    bool? isButtonEnabled,
    String? email,
    String? otp,
    String? message,
    int? secondsRemaining,
    bool? canResend,
  }) {
    return VerifyOtpState(
      isLoading: isLoading ?? this.isLoading,
      isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
      email: email ?? this.email,
      otp: otp ?? this.otp,
      message: message ?? this.message,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      canResend: canResend ?? this.canResend,
    );
  }
}

