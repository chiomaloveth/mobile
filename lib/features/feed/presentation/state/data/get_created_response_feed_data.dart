import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_created_response_feed_data.freezed.dart';
part 'get_created_response_feed_data.g.dart';

@freezed
class GetCreatedResponseFeedData with _$GetCreatedResponseFeedData {
  const factory GetCreatedResponseFeedData({
    @JsonKey(name: '_id') required String id,
    required String user,
    @Default('') String content,
    @Default([]) List<String> media,
    @Default([]) List<String> likes,
    @Default('everyone') String privacy,
    required DateTime createdAt,
    required DateTime updatedAt,
    @JsonKey(name: '__v') int? v,
    @JsonKey(name: 'commentCount') @Default(0) int commentCount,
  }) = _GetCreatedResponseFeedData;

  factory GetCreatedResponseFeedData.fromJson(Map<String, dynamic> json) =>
      _$GetCreatedResponseFeedDataFromJson(_sanitizeCreatedFeedJson(json));
}

/// Sanitizes created feed JSON to handle null values in media array
Map<String, dynamic> _sanitizeCreatedFeedJson(Map<String, dynamic> json) {
  if (json['media'] is List) {
    json['media'] = (json['media'] as List)
        .where((e) => e != null)
        .map((e) => e.toString())
        .toList();
  }
  return json;
}
