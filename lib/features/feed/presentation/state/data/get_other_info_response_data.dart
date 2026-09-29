import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_other_info_response_data.freezed.dart';
part 'get_other_info_response_data.g.dart';

@freezed
class GetOtherInfoResponseData with _$GetOtherInfoResponseData {
  const factory GetOtherInfoResponseData({
    required bool success,
    //required String message,
    required GetOtherInfoResponseDataInner data,
  }) = _GetOtherInfoResponseData;

  factory GetOtherInfoResponseData.fromJson(Map<String, dynamic> json) =>
      _$GetOtherInfoResponseDataFromJson(json);
}

@freezed
class GetOtherInfoResponseDataInner with _$GetOtherInfoResponseDataInner {
  const factory GetOtherInfoResponseDataInner({
    @JsonKey(name: '_id') required String id,
    String? profilePicture,
    String? username,
    required int postsCount,
    required int followersCount,
    required int followingCount,
    required bool isFollowing,
    required bool followsYou,
    String? instagram,
    String? youtube,
    String? link,
  }) = _GetOtherInfoResponseDataInner;

  factory GetOtherInfoResponseDataInner.fromJson(Map<String, dynamic> json) =>
      _$GetOtherInfoResponseDataInnerFromJson(json);
}
