import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_comment_response_data.dart';

part 'get_other_user_profile_post.freezed.dart';
part 'get_other_user_profile_post.g.dart';

@freezed
class GetOtherUserProfilePost with _$GetOtherUserProfilePost {
  const factory GetOtherUserProfilePost({
    required bool success,
    required List<GetOtherUserProfilePostData> data,
    required int page,
    required int pageSize,
    @Default(0) int totalPosts,
    @Default(0) int totalPages,
  }) = _GetOtherUserProfilePost;

  factory GetOtherUserProfilePost.fromJson(Map<String, dynamic> json) =>
      _$GetOtherUserProfilePostFromJson(json);
}

@freezed
class GetOtherUserProfilePostData with _$GetOtherUserProfilePostData {
  const factory GetOtherUserProfilePostData({
    @JsonKey(name: '_id') required String id,
    required MyUser user,
    String? content,
    @Default([]) List<String?> media,
    @Default([]) List<String> likes,
    @Default([]) List<String> shares,
    @Default([]) List<String> bookmarks,
    @Default([]) List<String?> tags,
    String? sharedFrom,
    required String privacy,
    @JsonKey(name: 'views') @Default(0) int views,
    @JsonKey(name: 'commentCount') @Default(0) int commentCount,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(true) bool allowComment,
  }) = _GetOtherUserProfilePostData;

  factory GetOtherUserProfilePostData.fromJson(Map<String, dynamic> json) =>
      _$GetOtherUserProfilePostDataFromJson(json);
}
