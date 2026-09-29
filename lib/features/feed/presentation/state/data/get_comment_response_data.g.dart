// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_comment_response_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GetCommentResponseDataImpl _$$GetCommentResponseDataImplFromJson(
        Map<String, dynamic> json) =>
    _$GetCommentResponseDataImpl(
      id: json['_id'] as String?,
      user: json['user'] == null
          ? null
          : MyUser.fromJson(json['user'] as Map<String, dynamic>),
      post: json['post'] as String?,
      content: json['content'] as String?,
      media: json['media'] as String?,
      likes:
          (json['likes'] as List<dynamic>?)?.map((e) => e as String).toList(),
      parentComment: json['parentComment'] as String?,
      type: json['type'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: (json['__v'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$GetCommentResponseDataImplToJson(
    _$GetCommentResponseDataImpl instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('_id', instance.id);
  writeNotNull('user', instance.user?.toJson());
  writeNotNull('post', instance.post);
  writeNotNull('content', instance.content);
  writeNotNull('media', instance.media);
  writeNotNull('likes', instance.likes);
  writeNotNull('parentComment', instance.parentComment);
  writeNotNull('type', instance.type);
  writeNotNull('createdAt', instance.createdAt);
  writeNotNull('updatedAt', instance.updatedAt);
  writeNotNull('__v', instance.v);
  return val;
}

_$MyUserImpl _$$MyUserImplFromJson(Map<String, dynamic> json) => _$MyUserImpl(
      id: json['_id'] as String?,
      profilePicture: json['profilePicture'] as String?,
      username: json['username'] as String?,
    );

Map<String, dynamic> _$$MyUserImplToJson(_$MyUserImpl instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('_id', instance.id);
  writeNotNull('profilePicture', instance.profilePicture);
  writeNotNull('username', instance.username);
  return val;
}
