import 'package:freezed_annotation/freezed_annotation.dart';

part 'follow_list_response_data.freezed.dart';
part 'follow_list_response_data.g.dart';

// ─── Shared user info embedded in follower/following items ───

@freezed
class FollowUserInfo with _$FollowUserInfo {
  const factory FollowUserInfo({
    @JsonKey(name: '_id') required String id,
    required String username,
    @Default('') String profilePicture,
  }) = _FollowUserInfo;

  factory FollowUserInfo.fromJson(Map<String, dynamic> json) =>
      _$FollowUserInfoFromJson(json);
}

// ─── GET /user/{userId}/followers ───

@freezed
class FollowerItem with _$FollowerItem {
  const factory FollowerItem({
    @JsonKey(name: '_id') required String id,
    required FollowUserInfo follower,
    required String following,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FollowerItem;

  factory FollowerItem.fromJson(Map<String, dynamic> json) =>
      _$FollowerItemFromJson(json);
}

@freezed
class GetFollowersResponse with _$GetFollowersResponse {
  const factory GetFollowersResponse({
    required bool success,
    required int count,
    required List<FollowerItem> data,
  }) = _GetFollowersResponse;

  factory GetFollowersResponse.fromJson(Map<String, dynamic> json) =>
      _$GetFollowersResponseFromJson(json);
}

// ─── GET /user/{userId}/following ───

@freezed
class FollowingItem with _$FollowingItem {
  const factory FollowingItem({
    @JsonKey(name: '_id') required String id,
    required String follower,
    required FollowingUserInfo following,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FollowingItem;

  factory FollowingItem.fromJson(Map<String, dynamic> json) =>
      _$FollowingItemFromJson(json);
}

/// Separate class for the "following" user object because
/// the field name collides with the parent's `following` field in Freezed.
@freezed
class FollowingUserInfo with _$FollowingUserInfo {
  const factory FollowingUserInfo({
    @JsonKey(name: '_id') required String id,
    required String username,
    @Default('') String profilePicture,
  }) = _FollowingUserInfo;

  factory FollowingUserInfo.fromJson(Map<String, dynamic> json) =>
      _$FollowingUserInfoFromJson(json);
}

@freezed
class GetFollowingResponse with _$GetFollowingResponse {
  const factory GetFollowingResponse({
    required bool success,
    required int count,
    required List<FollowingItem> data,
  }) = _GetFollowingResponse;

  factory GetFollowingResponse.fromJson(Map<String, dynamic> json) =>
      _$GetFollowingResponseFromJson(json);
}
