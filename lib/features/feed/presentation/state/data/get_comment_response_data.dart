import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_comment_response_data.freezed.dart';
part 'get_comment_response_data.g.dart';

@freezed
class GetCommentResponseData with _$GetCommentResponseData {
  const factory GetCommentResponseData({
    @JsonKey(name: '_id') String? id,
    @JsonKey(name: 'user') MyUser? user,
    @JsonKey(name: 'post') String? post,
    @JsonKey(name: 'content') String? content,
    @JsonKey(name: 'media') String? media,
    @JsonKey(name: 'likes') List<String>? likes,
    @JsonKey(name: 'parentComment') String? parentComment,
    @JsonKey(name: 'type') String? type,
    @JsonKey(name: 'createdAt') String? createdAt,
    @JsonKey(name: 'updatedAt') String? updatedAt,
    @JsonKey(name: '__v') int? v,
  }) = _GetCommentResponseData;

  factory GetCommentResponseData.fromJson(Map<String, dynamic> json) =>
      _$GetCommentResponseDataFromJson(json);
}

@freezed
class MyUser with _$MyUser {
  const factory MyUser({
    @JsonKey(name: '_id') String? id,
    @JsonKey(name: 'profilePicture') String? profilePicture,
    @JsonKey(name: 'username') String? username,
  }) = _MyUser;

  factory MyUser.fromJson(Map<String, dynamic> json) => _$MyUserFromJson(json);
}


