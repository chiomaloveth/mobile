import 'package:freezed_annotation/freezed_annotation.dart';

part 'unblock_user_response.freezed.dart';
part 'unblock_user_response.g.dart';

@freezed
class UnblockUserResponse with _$UnblockUserResponse {
  const factory UnblockUserResponse({
    required bool success,
    required String message,
    required List<String> blockedUsers,
  }) = _UnblockUserResponse;

  factory UnblockUserResponse.fromJson(Map<String, dynamic> json) =>
      _$UnblockUserResponseFromJson(json);
}
