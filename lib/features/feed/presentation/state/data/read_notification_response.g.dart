// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'read_notification_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReadNotificationResponseImpl _$$ReadNotificationResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ReadNotificationResponseImpl(
      success: json['success'] as bool,
      count: (json['count'] as num?)?.toInt() ?? 0,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      readCount: (json['readCount'] as num?)?.toInt() ?? 0,
      badgeCount: (json['badgeCount'] as num?)?.toInt() ?? 0,
      data: NotificationData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ReadNotificationResponseImplToJson(
        _$ReadNotificationResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'count': instance.count,
      'totalCount': instance.totalCount,
      'unreadCount': instance.unreadCount,
      'readCount': instance.readCount,
      'badgeCount': instance.badgeCount,
      'data': instance.data.toJson(),
    };
