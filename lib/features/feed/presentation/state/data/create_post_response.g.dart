// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_post_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreatePostResponseImpl _$$CreatePostResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$CreatePostResponseImpl(
      id: json['_id'] as String,
      user: json['user'] as String?,
      content: json['content'] as String? ?? '',
      media:
          (json['media'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      views: (json['views'] as num?)?.toInt() ?? 0,
      likes: json['likes'] as List<dynamic>? ?? const [],
      shares: json['shares'] as List<dynamic>? ?? const [],
      bookmarks: json['bookmarks'] as List<dynamic>? ?? const [],
      sharedFrom: json['sharedFrom'],
      music: json['music'] == null
          ? null
          : Music.fromJson(json['music'] as Map<String, dynamic>),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
      privacy: json['privacy'] as String? ?? 'everyone',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      v: (json['__v'] as num?)?.toInt(),
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      isFollowing: json['isFollowing'] as bool?,
      legacyId: json['id'] as String?,
      allowComment: json['allowComment'] as bool?,
      overlayText: json['overlayText'] as String?,
      overlayVideos: (json['overlayVideos'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$CreatePostResponseImplToJson(
    _$CreatePostResponseImpl instance) {
  final val = <String, dynamic>{
    '_id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('user', instance.user);
  val['content'] = instance.content;
  val['media'] = instance.media;
  val['views'] = instance.views;
  val['likes'] = instance.likes;
  val['shares'] = instance.shares;
  val['bookmarks'] = instance.bookmarks;
  writeNotNull('sharedFrom', instance.sharedFrom);
  writeNotNull('music', instance.music?.toJson());
  val['tags'] = instance.tags;
  val['privacy'] = instance.privacy;
  val['createdAt'] = instance.createdAt.toIso8601String();
  val['updatedAt'] = instance.updatedAt.toIso8601String();
  writeNotNull('__v', instance.v);
  val['commentCount'] = instance.commentCount;
  writeNotNull('isFollowing', instance.isFollowing);
  writeNotNull('id', instance.legacyId);
  writeNotNull('allowComment', instance.allowComment);
  writeNotNull('overlayText', instance.overlayText);
  writeNotNull('overlayVideos', instance.overlayVideos);
  return val;
}
