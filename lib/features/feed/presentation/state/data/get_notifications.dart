import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_notifications.freezed.dart';
part 'get_notifications.g.dart';

@freezed
class GetNotifications with _$GetNotifications {
  const factory GetNotifications({
    required bool success,
    @Default(0) int count,
    @Default(0) int totalCount,
    @Default(0) int unreadCount,
    @Default(0) int readCount,
    @Default(0) int badgeCount,
    required List<NotificationData> data,
  }) = _GetNotifications;

  factory GetNotifications.fromJson(Map<String, dynamic> json) => _$GetNotificationsFromJson(json);
}

@freezed
class NotificationData with _$NotificationData {
  const factory NotificationData({
    @JsonKey(name: '_id') required String id,
    String? user,
    dynamic actor,
    String? body,
    bool? read,
    String? recipient,
    dynamic sender, // Can be String (ID) or Map (User object)
    String? message,
    String? priority,
    bool? isRead,
    String? type,
    String? title,
    String? description,
    String? relatedId,
    String? onModel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _NotificationData;

  factory NotificationData.fromJson(Map<String, dynamic> json) => _$NotificationDataFromJson(json);
}

