// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_story_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateStoryDtoImpl _$$CreateStoryDtoImplFromJson(Map<String, dynamic> json) =>
    _$CreateStoryDtoImpl(
      media:
          (json['media'] as List<dynamic>?)?.map((e) => e as String).toList(),
      caption: json['caption'] as String?,
      overlayText: json['overlayText'] as String?,
      overlayVideos: (json['overlayVideos'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      music: json['music'] == null
          ? null
          : PostMusic.fromJson(json['music'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CreateStoryDtoImplToJson(
    _$CreateStoryDtoImpl instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('media', instance.media);
  writeNotNull('caption', instance.caption);
  writeNotNull('overlayText', instance.overlayText);
  writeNotNull('overlayVideos', instance.overlayVideos);
  writeNotNull('music', instance.music?.toJson());
  return val;
}
