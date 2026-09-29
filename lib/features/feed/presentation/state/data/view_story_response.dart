import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_story_response_data.dart';

part 'view_story_response.freezed.dart';
part 'view_story_response.g.dart';

@freezed
class ViewStoryResponse with _$ViewStoryResponse {
  const factory ViewStoryResponse({
    required bool success,
    required Update data,
  }) = _ViewStoryResponse;

  factory ViewStoryResponse.fromJson(Map<String, dynamic> json) =>
      _$ViewStoryResponseFromJson(json);
}
