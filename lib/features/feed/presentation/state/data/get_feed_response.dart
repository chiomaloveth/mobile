import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response_data.dart';

part 'get_feed_response.freezed.dart';
part 'get_feed_response.g.dart';

@freezed
class GetFeedResponse with _$GetFeedResponse {
  const factory GetFeedResponse({
    required bool success,
    required List<GetFeedResponseData> data,
  }) = _GetFeedResponse;

  factory GetFeedResponse.fromJson(Map<String, dynamic> json) =>
      _$GetFeedResponseFromJson(json);
}
