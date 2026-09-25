import 'package:flutter/foundation.dart';

@immutable
class ForgetPasswordState {
  final bool isLoading;
  final bool isButtonEnabled;
  final String email;

  const ForgetPasswordState({
    required this.isLoading,
    required this.isButtonEnabled,
    required this.email,
  });

  ForgetPasswordState copyWith({
    bool? isLoading,
    bool? isButtonEnabled,
    String? email,
  }) {
    return ForgetPasswordState(
      isLoading: isLoading ?? this.isLoading,
      isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
      email: email ?? this.email,
    );
  }
}
