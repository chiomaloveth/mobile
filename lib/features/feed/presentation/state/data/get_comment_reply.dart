import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_comment_response_data.dart';

part 'get_comment_reply.freezed.dart';
part 'get_comment_reply.g.dart';

@freezed
class GetCommentReply with _$GetCommentReply {
  const factory GetCommentReply({
    required bool success,
    required int count,
    required List<GetCommentReplyData> data,
  }) = _GetCommentReply;

  factory GetCommentReply.fromJson(Map<String, dynamic> json) => _$GetCommentReplyFromJson(json);
}

@freezed
class GetCommentReplyData with _$GetCommentReplyData {
  const factory GetCommentReplyData({
    @JsonKey(name: '_id') required String id,
    required MyUser user,
     String? post,
     String? content,
     List<dynamic>? media,
     List<dynamic>? likes,
     String? parentComment,
     String? type,
     String? createdAt,
     String? updatedAt,
     int? v,
     @JsonKey(name: 'id') String? replyId,
  }) = _GetCommentReplyData;

  factory GetCommentReplyData.fromJson(Map<String, dynamic> json) => _$GetCommentReplyDataFromJson(json);
}



