import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_comment_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response_data.dart';

part 'get_user_post_profle_response_data.freezed.dart';
part 'get_user_post_profle_response_data.g.dart';

/// Filters out null entries that the backend occasionally returns
/// in the media list (e.g. `media: [null]`).
List<String> _mediaFromJson(List<dynamic>? raw) =>
    (raw ?? []).whereType<String>().where((s) => s.isNotEmpty).toList();

@freezed
class GetUserPostProfleResponseData with _$GetUserPostProfleResponseData {
  const factory GetUserPostProfleResponseData({
    @JsonKey(name: '_id') required String id,
    required MyUser user,
    @Default('') String content,
    @JsonKey(fromJson: _mediaFromJson) @Default([]) List<String> media,
    @Default([]) List<String> likes,
    @Default([]) List<String> shares,
    @Default(0) int views,
    dynamic sharedFrom,
    Music? music,
    @Default('everyone') String privacy,
    required String createdAt,
    required String updatedAt,
    @JsonKey(name: '__v') int? v,
    @JsonKey(name: 'commentCount') @Default(0) int commentCount,
    @JsonKey(name: 'id') required String userPostId,
    @Default(true) bool allowComment,
    @Default([]) List<dynamic> bookmarks,
  }) = _GetUserPostProfleResponseData;

  factory GetUserPostProfleResponseData.fromJson(Map<String, dynamic> json) =>
      _$GetUserPostProfleResponseDataFromJson(json);
}
