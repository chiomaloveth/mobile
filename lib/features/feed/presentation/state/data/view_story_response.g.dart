// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'view_story_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ViewStoryResponseImpl _$$ViewStoryResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ViewStoryResponseImpl(
      success: json['success'] as bool,
      data: Update.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ViewStoryResponseImplToJson(
        _$ViewStoryResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data.toJson(),
    };
