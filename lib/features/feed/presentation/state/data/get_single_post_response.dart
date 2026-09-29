import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response_data.dart';

part 'get_single_post_response.freezed.dart';
part 'get_single_post_response.g.dart';

@freezed
class GetSinglePostResponse with _$GetSinglePostResponse {
  const factory GetSinglePostResponse({
    required bool success,
    required GetFeedResponseData data,
  }) = _GetSinglePostResponse;

  factory GetSinglePostResponse.fromJson(Map<String, dynamic> json) =>
      _$GetSinglePostResponseFromJson(json);
}
