import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_notifications.dart';

part 'read_notification_response.freezed.dart';
part 'read_notification_response.g.dart';

@freezed
class ReadNotificationResponse with _$ReadNotificationResponse {
  const factory ReadNotificationResponse({
    required bool success,
    @Default(0) int count,
    @Default(0) int totalCount,
    @Default(0) int unreadCount,
    @Default(0) int readCount,
    @Default(0) int badgeCount,
    required NotificationData data,
  }) = _ReadNotificationResponse;

  factory ReadNotificationResponse.fromJson(Map<String, dynamic> json) => _$ReadNotificationResponseFromJson(json);
}
