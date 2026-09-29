// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_post_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreatePostDtoImpl _$$CreatePostDtoImplFromJson(Map<String, dynamic> json) =>
    _$CreatePostDtoImpl(
      content: json['content'] as String?,
      media:
          (json['media'] as List<dynamic>?)?.map((e) => e as String).toList(),
      music: json['music'] == null
          ? null
          : PostMusic.fromJson(json['music'] as Map<String, dynamic>),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      overlayText: json['overlayText'] as String?,
      overlayVideos: (json['overlayVideos'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      allowComment: json['allowComment'] as bool?,
      taggedUsers: (json['taggedUsers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$CreatePostDtoImplToJson(_$CreatePostDtoImpl instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('content', instance.content);
  writeNotNull('media', instance.media);
  writeNotNull('music', instance.music?.toJson());
  writeNotNull('tags', instance.tags);
  writeNotNull('overlayText', instance.overlayText);
  writeNotNull('overlayVideos', instance.overlayVideos);
  writeNotNull('allowComment', instance.allowComment);
  writeNotNull('taggedUsers', instance.taggedUsers);
  return val;
}

_$PostMusicImpl _$$PostMusicImplFromJson(Map<String, dynamic> json) =>
    _$PostMusicImpl(
      thirdPartyId: json['thirdPartyId'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      audioUrl: json['audioUrl'] as String,
      coverImage: json['coverImage'] as String?,
    );

Map<String, dynamic> _$$PostMusicImplToJson(_$PostMusicImpl instance) {
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
