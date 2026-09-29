import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_comment_response_data.dart';

part 'create_reply_comment_response.freezed.dart';
part 'create_reply_comment_response.g.dart';

@freezed
class CreateReplyCommentResponse with _$CreateReplyCommentResponse {
  const factory CreateReplyCommentResponse({
    required MyUser user,
     String? post,
     String? content,
     String? media,
     List<dynamic>? likes,
     String? parentComment,
     String? type,
     @JsonKey(name: '_id') String? id,
     String? createdAt,
     String? updatedAt,
     int? v,
     @JsonKey(name: 'id') String? commentReplyId,

  }) = _CreateReplyCommentResponse;

  factory CreateReplyCommentResponse.fromJson(Map<String, dynamic> json) => _$CreateReplyCommentResponseFromJson(json);
}

