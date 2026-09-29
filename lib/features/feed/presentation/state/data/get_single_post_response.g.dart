// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_single_post_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GetSinglePostResponseImpl _$$GetSinglePostResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$GetSinglePostResponseImpl(
      success: json['success'] as bool,
      data: GetFeedResponseData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$GetSinglePostResponseImplToJson(
        _$GetSinglePostResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data.toJson(),
    };
