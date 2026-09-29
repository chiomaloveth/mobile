import 'package:freezed_annotation/freezed_annotation.dart';

part 'share_response_data.freezed.dart';
part 'share_response_data.g.dart';

@freezed
class ShareResponseData with _$ShareResponseData {
  const factory ShareResponseData({
    @JsonKey(name: 'success') required bool success,
    @JsonKey(name: 'message') required String message,
    @JsonKey(name: 'data') required ShareData data,
  }) = _ShareResponseData;

  factory ShareResponseData.fromJson(Map<String, dynamic> json) =>
      _$ShareResponseDataFromJson(json);
}

@freezed
class ShareData with _$ShareData {
  const factory ShareData({
    @JsonKey(name: '_id') required String id,
    @JsonKey(name: 'user') required String user,
    @JsonKey(name: 'content') required String content,
    @JsonKey(name: 'media') required List<String> media,
    @JsonKey(name: 'likes') required List<String> likes,
    @JsonKey(name: 'shares') required List<String> shares,
    @JsonKey(name: 'sharedFrom') dynamic sharedFrom,
    @JsonKey(name: 'privacy') required String privacy,
    @JsonKey(name: 'createdAt') required DateTime createdAt,
    @JsonKey(name: 'updatedAt') required DateTime updatedAt,
    @JsonKey(name: '__v') int? v,
  }) = _ShareData;

  factory ShareData.fromJson(Map<String, dynamic> json) =>
      _$ShareDataFromJson(json);
}

