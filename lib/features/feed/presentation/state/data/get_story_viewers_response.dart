import 'package:freezed_annotation/freezed_annotation.dart';
import 'get_story_response_data.dart';

part 'get_story_viewers_response.freezed.dart';
part 'get_story_viewers_response.g.dart';

@freezed
class GetStoryViewersResponse with _$GetStoryViewersResponse {
  const factory GetStoryViewersResponse({
    required bool success,
    required String message,
    required StoryViewersData data,
  }) = _GetStoryViewersResponse;

  factory GetStoryViewersResponse.fromJson(Map<String, dynamic> json) =>
      _$GetStoryViewersResponseFromJson(json);
}

@freezed
class StoryViewersData with _$StoryViewersData {
  const factory StoryViewersData({
    required int totalViews,
    required List<StoryViewer> viewers,
  }) = _StoryViewersData;

  factory StoryViewersData.fromJson(Map<String, dynamic> json) =>
      _$StoryViewersDataFromJson(json);
}
