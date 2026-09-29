import 'package:freezed_annotation/freezed_annotation.dart';

part 'follow_response_data.freezed.dart';
part 'follow_response_data.g.dart';

@freezed
class FollowResponseData with _$FollowResponseData {
  const factory FollowResponseData({
    required bool success,
    required String message,
  }) = _FollowResponseData;

  factory FollowResponseData.fromJson(Map<String, dynamic> json) => _$FollowResponseDataFromJson(json);
}

