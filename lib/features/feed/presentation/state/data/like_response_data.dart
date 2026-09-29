import 'package:freezed_annotation/freezed_annotation.dart';

part 'like_response_data.freezed.dart';
part 'like_response_data.g.dart';

@freezed
class LikeResponseData with _$LikeResponseData {
  const factory LikeResponseData({
    @JsonKey(name: 'liked') bool? liked,
  }) = _LikeResponseData;

  factory LikeResponseData.fromJson(Map<String, dynamic> json) => _$LikeResponseDataFromJson(json);
}

