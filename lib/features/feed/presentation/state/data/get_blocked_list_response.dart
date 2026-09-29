import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_blocked_list_response.freezed.dart';
part 'get_blocked_list_response.g.dart';

@freezed
class GetBlockedListResponse with _$GetBlockedListResponse {
  const factory GetBlockedListResponse({
    required bool success,
    required List<BlockedUserData> data,
  }) = _GetBlockedListResponse;

  factory GetBlockedListResponse.fromJson(Map<String, dynamic> json) =>
      _$GetBlockedListResponseFromJson(json);
}

@freezed
class BlockedUserData with _$BlockedUserData {
  const factory BlockedUserData({
    @JsonKey(name: '_id') required String id,
    @Default('') String phone,
    @Default('') String profilePicture,
    String? username,
  }) = _BlockedUserData;

  factory BlockedUserData.fromJson(Map<String, dynamic> json) =>
      _$BlockedUserDataFromJson(json);
}
