import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_user.freezed.dart';
part 'feed_user.g.dart';

@freezed
class FeedUser with _$FeedUser {
  const factory FeedUser({
    @JsonKey(name: '_id') required String id,
    @Default('') String profilePicture,
    @Default('') String username,
  }) = _FeedUser;

  factory FeedUser.fromJson(Map<String, dynamic> json) =>
      _$FeedUserFromJson(json);
}
