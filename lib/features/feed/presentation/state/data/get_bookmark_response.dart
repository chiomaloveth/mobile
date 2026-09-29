import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_comment_response_data.dart';

part 'get_bookmark_response.freezed.dart';
part 'get_bookmark_response.g.dart';

@freezed
class GetBookmarkResponse with _$GetBookmarkResponse {
  const factory GetBookmarkResponse({
    required bool success,
    required int count,
    required List<GetBookmarkResponseData> data,
  }) = _GetBookmarkResponse;

  factory GetBookmarkResponse.fromJson(Map<String, dynamic> json) =>
      _$GetBookmarkResponseFromJson(json);
}

/// Null-safe media deserializer — filters out null / non-string entries.
List<String> _bookmarkMediaFromJson(List<dynamic>? raw) =>
    (raw ?? []).whereType<String>().where((s) => s.isNotEmpty).toList();

/// Each item in the bookmark data array IS the post itself (no extra wrapper).
/// The backend returns post objects directly: user object, content, media, etc.
@freezed
class GetBookmarkResponseData with _$GetBookmarkResponseData {
  const factory GetBookmarkResponseData({
    @JsonKey(name: '_id') required String id,
    required MyUser user,
    @Default('') String content,
    @JsonKey(fromJson: _bookmarkMediaFromJson) @Default([]) List<String> media,
    @Default([]) List<dynamic> likes,
    @Default([]) List<dynamic> shares,
    @Default([]) List<dynamic> bookmarks,
    dynamic sharedFrom,
    @Default('everyone') String privacy,
    required String createdAt,
    required String updatedAt,
    @JsonKey(name: '__v') int? v,
    @JsonKey(name: 'commentCount') @Default(0) int commentCount,
    @JsonKey(name: 'id') String? bookMarkId,
  }) = _GetBookmarkResponseData;

  factory GetBookmarkResponseData.fromJson(Map<String, dynamic> json) =>
      _$GetBookmarkResponseDataFromJson(json);
}
