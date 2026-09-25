import 'package:flutter/foundation.dart';

@immutable
class PasswordResetState {
  final bool isLoading;
  final bool isButtonEnabled;
  final bool passwordVisible;
  final bool confirmPasswordVisible;
  final String message;

  const PasswordResetState({
    this.isLoading = false,
    this.isButtonEnabled = false,
    this.passwordVisible = false,
    this.confirmPasswordVisible = false,
    this.message = '',
  });

  PasswordResetState copyWith({
    bool? isLoading,
    bool? isButtonEnabled,
    bool? passwordVisible,
    bool? confirmPasswordVisible,
    String? email,
    String? message,
  }) {
    return PasswordResetState(
      isLoading: isLoading ?? this.isLoading,
      isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
      passwordVisible: passwordVisible ?? this.passwordVisible,
      confirmPasswordVisible: confirmPasswordVisible ?? this.confirmPasswordVisible,
      message: message ?? this.message,
    );
  }
}
