// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_notifications.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GetNotificationsImpl _$$GetNotificationsImplFromJson(
        Map<String, dynamic> json) =>
    _$GetNotificationsImpl(
      success: json['success'] as bool,
      count: (json['count'] as num?)?.toInt() ?? 0,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      readCount: (json['readCount'] as num?)?.toInt() ?? 0,
      badgeCount: (json['badgeCount'] as num?)?.toInt() ?? 0,
      data: (json['data'] as List<dynamic>)
          .map((e) => NotificationData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$GetNotificationsImplToJson(
        _$GetNotificationsImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'count': instance.count,
      'totalCount': instance.totalCount,
      'unreadCount': instance.unreadCount,
      'readCount': instance.readCount,
      'badgeCount': instance.badgeCount,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

_$NotificationDataImpl _$$NotificationDataImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationDataImpl(
      id: json['_id'] as String,
      user: json['user'] as String?,
      actor: json['actor'],
      body: json['body'] as String?,
      read: json['read'] as bool?,
      recipient: json['recipient'] as String?,
      sender: json['sender'],
      message: json['message'] as String?,
      priority: json['priority'] as String?,
      isRead: json['isRead'] as bool?,
      type: json['type'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      relatedId: json['relatedId'] as String?,
      onModel: json['onModel'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$NotificationDataImplToJson(
    _$NotificationDataImpl instance) {
  final val = <String, dynamic>{
    '_id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('user', instance.user);
  writeNotNull('actor', instance.actor);
  writeNotNull('body', instance.body);
  writeNotNull('read', instance.read);
  writeNotNull('recipient', instance.recipient);
  writeNotNull('sender', instance.sender);
  writeNotNull('message', instance.message);
  writeNotNull('priority', instance.priority);
  writeNotNull('isRead', instance.isRead);
  writeNotNull('type', instance.type);
  writeNotNull('title', instance.title);
  writeNotNull('description', instance.description);
  writeNotNull('relatedId', instance.relatedId);
  writeNotNull('onModel', instance.onModel);
  writeNotNull('createdAt', instance.createdAt?.toIso8601String());
  writeNotNull('updatedAt', instance.updatedAt?.toIso8601String());
  return val;
}
