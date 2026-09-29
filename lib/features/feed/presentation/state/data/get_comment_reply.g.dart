// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_comment_reply.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GetCommentReplyImpl _$$GetCommentReplyImplFromJson(
        Map<String, dynamic> json) =>
    _$GetCommentReplyImpl(
      success: json['success'] as bool,
      count: (json['count'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => GetCommentReplyData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$GetCommentReplyImplToJson(
        _$GetCommentReplyImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'count': instance.count,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

_$GetCommentReplyDataImpl _$$GetCommentReplyDataImplFromJson(
        Map<String, dynamic> json) =>
    _$GetCommentReplyDataImpl(
      id: json['_id'] as String,
      user: MyUser.fromJson(json['user'] as Map<String, dynamic>),
      post: json['post'] as String?,
      content: json['content'] as String?,
      media: json['media'] as List<dynamic>?,
      likes: json['likes'] as List<dynamic>?,
      parentComment: json['parentComment'] as String?,
      type: json['type'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: (json['v'] as num?)?.toInt(),
      replyId: json['id'] as String?,
    );

Map<String, dynamic> _$$GetCommentReplyDataImplToJson(
    _$GetCommentReplyDataImpl instance) {
  final val = <String, dynamic>{
    '_id': instance.id,
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
  writeNotNull('createdAt', instance.createdAt);
  writeNotNull('updatedAt', instance.updatedAt);
  writeNotNull('v', instance.v);
  writeNotNull('id', instance.replyId);
  return val;
}
