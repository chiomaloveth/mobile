import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_comment.freezed.dart';
part 'get_comment.g.dart';

@freezed
class GetComment with _$GetComment {
  const GetComment._();

  const factory GetComment({
    @JsonKey(name: '_id') required String id,
    @JsonKey(name: 'user') required CommentUser user,
    @JsonKey(name: 'post') required String post,
    @JsonKey(name: 'content') String? content,
    @JsonKey(name: 'media') String? media,
    @Default([]) List<String> likes,
    String? parentComment,
    @Default('text') String type,
    String? createdAt,
    String? updatedAt,
    @JsonKey(name: '__v') @Default(0) int v,
    @Default([]) List<GetComment> replies,
    // Some endpoints might return 'id' instead of '_id' or both
    @JsonKey(name: 'id') String? commentId,
  }) = _GetComment;

  factory GetComment.fromJson(Map<String, dynamic> json) =>
      _$GetCommentFromJson(json);

  bool isLikedBy(String userId) => likes.contains(userId);

  String getTimeAgo() {
    if (createdAt == null || createdAt!.isEmpty) return '';

    try {
      final date = DateTime.parse(createdAt!);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${difference.inDays ~/ 7}w ago';
      }
    } catch (_) {
      return createdAt ?? '';
    }
  }
}

@freezed
class CommentUser with _$CommentUser {
  const factory CommentUser({
    @JsonKey(name: '_id') required String id,
    @JsonKey(name: 'profilePicture') @Default('') String profilePicture,
    @JsonKey(name: 'username') @Default('Unknown') String username,
  }) = _CommentUser;

  factory CommentUser.fromJson(Map<String, dynamic> json) =>
      _$CommentUserFromJson(json);
}
