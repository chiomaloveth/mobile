import 'package:flutter/foundation.dart';

@immutable
class LoginState {
  final bool isLoading;
  final bool isButtonEnabled;
  final bool passwordVisible;
  final bool rememberMe;

  const LoginState({
    this.isLoading = false,
    this.isButtonEnabled = false,
    this.passwordVisible = false,
    this.rememberMe = false,
  });

  LoginState copyWith({
    bool? isLoading,
    bool? isButtonEnabled,
    bool? passwordVisible,
    bool? rememberMe,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
      passwordVisible: passwordVisible ?? this.passwordVisible,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}
