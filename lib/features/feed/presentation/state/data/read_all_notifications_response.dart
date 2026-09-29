import 'package:freezed_annotation/freezed_annotation.dart';

part 'read_all_notifications_response.freezed.dart';
part 'read_all_notifications_response.g.dart';

@freezed
class ReadAllNotificationsResponse with _$ReadAllNotificationsResponse {
  const factory ReadAllNotificationsResponse({
    required bool success,
    String? message,
    @Default(0) int count,
    @Default(0) int totalCount,
    @Default(0) int unreadCount,
    @Default(0) int readCount,
    @Default(0) int badgeCount,
  }) = _ReadAllNotificationsResponse;

  factory ReadAllNotificationsResponse.fromJson(Map<String, dynamic> json) =>
      _$ReadAllNotificationsResponseFromJson(json);
}
