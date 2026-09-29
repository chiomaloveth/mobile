// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'read_all_notifications_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReadAllNotificationsResponseImpl _$$ReadAllNotificationsResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ReadAllNotificationsResponseImpl(
      success: json['success'] as bool,
      message: json['message'] as String?,
      count: (json['count'] as num?)?.toInt() ?? 0,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      readCount: (json['readCount'] as num?)?.toInt() ?? 0,
      badgeCount: (json['badgeCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ReadAllNotificationsResponseImplToJson(
    _$ReadAllNotificationsResponseImpl instance) {
  final val = <String, dynamic>{
    'success': instance.success,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('message', instance.message);
  val['count'] = instance.count;
  val['totalCount'] = instance.totalCount;
  val['unreadCount'] = instance.unreadCount;
  val['readCount'] = instance.readCount;
  val['badgeCount'] = instance.badgeCount;
  return val;
}
