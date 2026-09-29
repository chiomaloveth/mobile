// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unblock_user_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UnblockUserResponseImpl _$$UnblockUserResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$UnblockUserResponseImpl(
      success: json['success'] as bool,
      message: json['message'] as String,
      blockedUsers: (json['blockedUsers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$UnblockUserResponseImplToJson(
        _$UnblockUserResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'blockedUsers': instance.blockedUsers,
    };
