// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_story_response_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GetStoryResponseDataImpl _$$GetStoryResponseDataImplFromJson(
        Map<String, dynamic> json) =>
    _$GetStoryResponseDataImpl(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((e) => StoryData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$GetStoryResponseDataImplToJson(
        _$GetStoryResponseDataImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

_$StoryDataImpl _$$StoryDataImplFromJson(Map<String, dynamic> json) =>
    _$StoryDataImpl(
      id: json['_id'] as String?,
      user: json['user'] == null
          ? null
          : MyUser.fromJson(json['user'] as Map<String, dynamic>),
      updates: (json['updates'] as List<dynamic>?)
          ?.map((e) => Update.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$StoryDataImplToJson(_$StoryDataImpl instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('_id', instance.id);
  writeNotNull('user', instance.user?.toJson());
  writeNotNull('updates', instance.updates?.map((e) => e.toJson()).toList());
  return val;
}

_$UpdateImpl _$$UpdateImplFromJson(Map<String, dynamic> json) => _$UpdateImpl(
      updateId: json['_id'] as String?,
      user: json['user'] == null
          ? null
          : MyUser.fromJson(json['user'] as Map<String, dynamic>),
      media: json['media'] as String?,
      mediaType: json['mediaType'] as String?,
      caption: json['caption'] as String?,
      viewers: (json['viewers'] as List<dynamic>?)
          ?.map((e) => StoryViewer.fromJson(e as Map<String, dynamic>))
          .toList(),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      v: (json['__v'] as num?)?.toInt(),
      bgColor: json['bgColor'] as String?,
      backgroundColor: (json['backgroundColor'] as num?)?.toInt(),
      viewCount: (json['viewCount'] as num?)?.toInt(),
      id: json['id'] as String?,
      hasViewed: json['hasViewed'] as bool?,
      overlayText: json['overlayText'] as String?,
      overlayVideos: (json['overlayVideos'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      overlays: json['overlays'] as List<dynamic>?,
      music: json['music'] == null
          ? null
          : Music.fromJson(json['music'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UpdateImplToJson(_$UpdateImpl instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('_id', instance.updateId);
  writeNotNull('user', instance.user?.toJson());
  writeNotNull('media', instance.media);
  writeNotNull('mediaType', instance.mediaType);
  writeNotNull('caption', instance.caption);
  writeNotNull('viewers', instance.viewers?.map((e) => e.toJson()).toList());
  writeNotNull('expiresAt', instance.expiresAt?.toIso8601String());
  writeNotNull('createdAt', instance.createdAt?.toIso8601String());
  writeNotNull('updatedAt', instance.updatedAt?.toIso8601String());
  writeNotNull('__v', instance.v);
  writeNotNull('bgColor', instance.bgColor);
  writeNotNull('backgroundColor', instance.backgroundColor);
  writeNotNull('viewCount', instance.viewCount);
  writeNotNull('id', instance.id);
  writeNotNull('hasViewed', instance.hasViewed);
  writeNotNull('overlayText', instance.overlayText);
  writeNotNull('overlayVideos', instance.overlayVideos);
  writeNotNull('overlays', instance.overlays);
  writeNotNull('music', instance.music?.toJson());
  return val;
}

_$StoryViewerImpl _$$StoryViewerImplFromJson(Map<String, dynamic> json) =>
    _$StoryViewerImpl(
      id: json['_id'] as String?,
      userId: json['userId'] as String?,
      username: json['username'] as String?,
      profilePicture: json['profilePicture'] as String?,
      viewedAt: json['viewedAt'] == null
          ? null
          : DateTime.parse(json['viewedAt'] as String),
    );

Map<String, dynamic> _$$StoryViewerImplToJson(_$StoryViewerImpl instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('_id', instance.id);
  writeNotNull('userId', instance.userId);
  writeNotNull('username', instance.username);
  writeNotNull('profilePicture', instance.profilePicture);
  writeNotNull('viewedAt', instance.viewedAt?.toIso8601String());
  return val;
}
