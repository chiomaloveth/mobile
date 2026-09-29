import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_search_result.freezed.dart';
part 'user_search_result.g.dart';

@freezed
class UserSearchResult with _$UserSearchResult {
  const factory UserSearchResult({
    @JsonKey(name: '_id') required String id,
    required String username,
    @Default('') String profilePicture,
    String? fullName,
  }) = _UserSearchResult;

  factory UserSearchResult.fromJson(Map<String, dynamic> json) =>
      _$UserSearchResultFromJson(json);
}
