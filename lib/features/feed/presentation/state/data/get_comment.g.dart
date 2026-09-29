// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GetCommentImpl _$$GetCommentImplFromJson(Map<String, dynamic> json) =>
    _$GetCommentImpl(
      id: json['_id'] as String,
      user: CommentUser.fromJson(json['user'] as Map<String, dynamic>),
      post: json['post'] as String,
      content: json['content'] as String?,
      media: json['media'] as String?,
      likes:
          (json['likes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      parentComment: json['parentComment'] as String?,
      type: json['type'] as String? ?? 'text',
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: (json['__v'] as num?)?.toInt() ?? 0,
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => GetComment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      commentId: json['id'] as String?,
    );

Map<String, dynamic> _$$GetCommentImplToJson(_$GetCommentImpl instance) {
  final val = <String, dynamic>{
    '_id': instance.id,
    'user': instance.user.toJson(),
    'post': instance.post,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('content', instance.content);
  writeNotNull('media', instance.media);
  val['likes'] = instance.likes;
  writeNotNull('parentComment', instance.parentComment);
  val['type'] = instance.type;
  writeNotNull('createdAt', instance.createdAt);
  writeNotNull('updatedAt', instance.updatedAt);
  val['__v'] = instance.v;
  val['replies'] = instance.replies.map((e) => e.toJson()).toList();
  writeNotNull('id', instance.commentId);
  return val;
}

_$CommentUserImpl _$$CommentUserImplFromJson(Map<String, dynamic> json) =>
    _$CommentUserImpl(
      id: json['_id'] as String,
      profilePicture: json['profilePicture'] as String? ?? '',
      username: json['username'] as String? ?? 'Unknown',
    );

Map<String, dynamic> _$$CommentUserImplToJson(_$CommentUserImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'profilePicture': instance.profilePicture,
      'username': instance.username,
    };
