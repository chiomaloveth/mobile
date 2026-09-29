// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_story_viewers_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GetStoryViewersResponseImpl _$$GetStoryViewersResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$GetStoryViewersResponseImpl(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: StoryViewersData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$GetStoryViewersResponseImplToJson(
        _$GetStoryViewersResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data.toJson(),
    };

_$StoryViewersDataImpl _$$StoryViewersDataImplFromJson(
        Map<String, dynamic> json) =>
    _$StoryViewersDataImpl(
      totalViews: (json['totalViews'] as num).toInt(),
      viewers: (json['viewers'] as List<dynamic>)
          .map((e) => StoryViewer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$StoryViewersDataImplToJson(
        _$StoryViewersDataImpl instance) =>
    <String, dynamic>{
      'totalViews': instance.totalViews,
      'viewers': instance.viewers.map((e) => e.toJson()).toList(),
    };
