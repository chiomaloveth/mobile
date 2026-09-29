// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_reply_comment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateReplyCommentResponseImpl _$$CreateReplyCommentResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateReplyCommentResponseImpl(
      user: MyUser.fromJson(json['user'] as Map<String, dynamic>),
      post: json['post'] as String?,
      content: json['content'] as String?,
      media: json['media'] as String?,
      likes: json['likes'] as List<dynamic>?,
      parentComment: json['parentComment'] as String?,
      type: json['type'] as String?,
      id: json['_id'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: (json['v'] as num?)?.toInt(),
      commentReplyId: json['id'] as String?,
    );

Map<String, dynamic> _$$CreateReplyCommentResponseImplToJson(
    _$CreateReplyCommentResponseImpl instance) {
  final val = <String, dynamic>{
    'user': instance.user.toJson(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('post', instance.post);
  writeNotNull('content', instance.content);
  writeNotNull('media', instance.media);
  writeNotNull('likes', instance.likes);
  writeNotNull('parentComment', instance.parentComment);
  writeNotNull('type', instance.type);
  writeNotNull('_id', instance.id);
  writeNotNull('createdAt', instance.createdAt);
  writeNotNull('updatedAt', instance.updatedAt);
  writeNotNull('v', instance.v);
  writeNotNull('id', instance.commentReplyId);
  return val;
}
