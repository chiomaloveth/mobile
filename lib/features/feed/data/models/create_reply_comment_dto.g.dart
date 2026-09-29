// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_reply_comment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateReplyCommentDtoImpl _$$CreateReplyCommentDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateReplyCommentDtoImpl(
      parentComment: json['parentComment'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$$CreateReplyCommentDtoImplToJson(
        _$CreateReplyCommentDtoImpl instance) =>
    <String, dynamic>{
      'parentComment': instance.parentComment,
      'content': instance.content,
    };
