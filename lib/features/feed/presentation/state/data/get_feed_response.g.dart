// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_feed_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GetFeedResponseImpl _$$GetFeedResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$GetFeedResponseImpl(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((e) => GetFeedResponseData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$GetFeedResponseImplToJson(
        _$GetFeedResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };
