import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_reply_comment_dto.freezed.dart';
part 'create_reply_comment_dto.g.dart';

@freezed
class CreateReplyCommentDto with _$CreateReplyCommentDto {
  const factory CreateReplyCommentDto({
    required String parentComment,
    required String content,
  }) = _CreateReplyCommentDto;

  factory CreateReplyCommentDto.fromJson(Map<String, dynamic> json) => _$CreateReplyCommentDtoFromJson(json);
}
