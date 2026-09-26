import 'dart:io';

class AddProfileInfoState {
  final bool isLoading;
  final bool isButtonEnabled;
  final String username;
  final File? image;
  final String message;

  const AddProfileInfoState({
    this.isLoading = false,
    this.isButtonEnabled = false,
    this.username = '',
    this.image,
    this.message = '',
  });

  AddProfileInfoState copyWith({
    bool? isLoading,
    bool? isButtonEnabled,
    String? username,
    File? image,
    String? message,
  }) {
    return AddProfileInfoState(
      isLoading: isLoading ?? this.isLoading,
      isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
      username: username ?? this.username,
      image: image ?? this.image,
      message: message ?? this.message,
    );
  }
}
