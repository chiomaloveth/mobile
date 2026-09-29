import 'package:freezed_annotation/freezed_annotation.dart';

part 'block_user_response.freezed.dart';
part 'block_user_response.g.dart';

@freezed
class BlockUserResponse with _$BlockUserResponse {
  const factory BlockUserResponse({
    required bool success,
    required String message,
  }) = _BlockUserResponse;

  factory BlockUserResponse.fromJson(Map<String, dynamic> json) =>
      _$BlockUserResponseFromJson(json);
}
