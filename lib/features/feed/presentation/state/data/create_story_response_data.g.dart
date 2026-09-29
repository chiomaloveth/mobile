// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_story_response_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateStoryResponseDataImpl _$$CreateStoryResponseDataImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateStoryResponseDataImpl(
      success: json['success'] as bool?,
      data: json['data'] == null
          ? null
          : CreateStoryData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CreateStoryResponseDataImplToJson(
    _$CreateStoryResponseDataImpl instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('success', instance.success);
  writeNotNull('data', instance.data?.toJson());
  return val;
}

_$CreateStoryDataImpl _$$CreateStoryDataImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateStoryDataImpl(
      user: json['user'] as String?,
      media: json['media'] as String?,
      mediaType: json['mediaType'] as String?,
      caption: json['caption'] as String?,
      id: json['_id'] as String?,
      viewers: json['viewers'] as List<dynamic>?,
      expiresAt: json['expiresAt'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      overlayText: json['overlayText'] as String?,
      overlayVideos: (json['overlayVideos'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      v: (json['__v'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CreateStoryDataImplToJson(
    _$CreateStoryDataImpl instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('user', instance.user);
  writeNotNull('media', instance.media);
  writeNotNull('mediaType', instance.mediaType);
  writeNotNull('caption', instance.caption);
  writeNotNull('_id', instance.id);
  writeNotNull('viewers', instance.viewers);
  writeNotNull('expiresAt', instance.expiresAt);
  writeNotNull('createdAt', instance.createdAt);
  writeNotNull('updatedAt', instance.updatedAt);
  writeNotNull('overlayText', instance.overlayText);
  writeNotNull('overlayVideos', instance.overlayVideos);
  writeNotNull('__v', instance.v);
  return val;
}
