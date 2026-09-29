// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_feed_response_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GetFeedResponseDataImpl _$$GetFeedResponseDataImplFromJson(
        Map<String, dynamic> json) =>
    _$GetFeedResponseDataImpl(
      id: json['_id'] as String,
      user: FeedUser.fromJson(json['user'] as Map<String, dynamic>),
      content: json['content'] as String? ?? '',
      media:
          (json['media'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      likes: json['likes'] as List<dynamic>? ?? const [],
      shares: json['shares'] as List<dynamic>? ?? const [],
      bookmarks: json['bookmarks'] as List<dynamic>? ?? const [],
      views: (json['views'] as num?)?.toInt() ?? 0,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      isFollowing: json['isFollowing'] as bool? ?? false,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      bookmarkCount: (json['bookmarkCount'] as num?)?.toInt() ?? 0,
      overlays: json['overlays'] as List<dynamic>?,
      overlayText: json['overlayText'] as String?,
      overlayVideos: (json['overlayVideos'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      sharedFrom: json['sharedFrom'],
      music: json['music'] == null
          ? null
          : Music.fromJson(json['music'] as Map<String, dynamic>),
      privacy: json['privacy'] as String? ?? 'everyone',
      allowComment: json['allowComment'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      v: (json['__v'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$GetFeedResponseDataImplToJson(
    _$GetFeedResponseDataImpl instance) {
  final val = <String, dynamic>{
    '_id': instance.id,
    'user': instance.user.toJson(),
    'content': instance.content,
    'media': instance.media,
    'likes': instance.likes,
    'shares': instance.shares,
    'bookmarks': instance.bookmarks,
    'views': instance.views,
    'isBookmarked': instance.isBookmarked,
    'isFollowing': instance.isFollowing,
    'commentCount': instance.commentCount,
    'tags': instance.tags,
    'bookmarkCount': instance.bookmarkCount,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('overlays', instance.overlays);
  writeNotNull('overlayText', instance.overlayText);
  writeNotNull('overlayVideos', instance.overlayVideos);
  writeNotNull('sharedFrom', instance.sharedFrom);
  writeNotNull('music', instance.music?.toJson());
  val['privacy'] = instance.privacy;
  val['allowComment'] = instance.allowComment;
  val['createdAt'] = instance.createdAt.toIso8601String();
  val['updatedAt'] = instance.updatedAt.toIso8601String();
  val['__v'] = instance.v;
  return val;
}

_$MusicImpl _$$MusicImplFromJson(Map<String, dynamic> json) => _$MusicImpl(
      thirdPartyId: json['thirdPartyId'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      audioUrl: json['audioUrl'] as String,
      coverImage: json['coverImage'] as String?,
    );

Map<String, dynamic> _$$MusicImplToJson(_$MusicImpl instance) {
  final val = <String, dynamic>{
    'thirdPartyId': instance.thirdPartyId,
    'title': instance.title,
    'artist': instance.artist,
    'audioUrl': instance.audioUrl,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('coverImage', instance.coverImage);
  return val;
}
