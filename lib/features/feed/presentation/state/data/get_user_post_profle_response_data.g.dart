// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_user_post_profle_response_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GetUserPostProfleResponseDataImpl
    _$$GetUserPostProfleResponseDataImplFromJson(Map<String, dynamic> json) =>
        _$GetUserPostProfleResponseDataImpl(
          id: json['_id'] as String,
          user: MyUser.fromJson(json['user'] as Map<String, dynamic>),
          content: json['content'] as String? ?? '',
          media: json['media'] == null
              ? const []
              : _mediaFromJson(json['media'] as List?),
          likes: (json['likes'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              const [],
          shares: (json['shares'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              const [],
          views: (json['views'] as num?)?.toInt() ?? 0,
          sharedFrom: json['sharedFrom'],
          music: json['music'] == null
              ? null
              : Music.fromJson(json['music'] as Map<String, dynamic>),
          privacy: json['privacy'] as String? ?? 'everyone',
          createdAt: json['createdAt'] as String,
          updatedAt: json['updatedAt'] as String,
          v: (json['__v'] as num?)?.toInt(),
          commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
          userPostId: json['id'] as String,
          allowComment: json['allowComment'] as bool? ?? true,
          bookmarks: json['bookmarks'] as List<dynamic>? ?? const [],
        );

Map<String, dynamic> _$$GetUserPostProfleResponseDataImplToJson(
    _$GetUserPostProfleResponseDataImpl instance) {
  final val = <String, dynamic>{
    '_id': instance.id,
    'user': instance.user.toJson(),
    'content': instance.content,
    'media': instance.media,
    'likes': instance.likes,
    'shares': instance.shares,
    'views': instance.views,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('sharedFrom', instance.sharedFrom);
  writeNotNull('music', instance.music?.toJson());
  val['privacy'] = instance.privacy;
  val['createdAt'] = instance.createdAt;
  val['updatedAt'] = instance.updatedAt;
  writeNotNull('__v', instance.v);
  val['commentCount'] = instance.commentCount;
  val['id'] = instance.userPostId;
  val['allowComment'] = instance.allowComment;
  val['bookmarks'] = instance.bookmarks;
  return val;
}
