import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:qik_talk/features/feed/data/models/create_post_dto.dart';

part 'create_story_dto.freezed.dart';
part 'create_story_dto.g.dart';

@freezed
class CreateStoryDto with _$CreateStoryDto {
  const factory CreateStoryDto({
    List<String>? media,
    String? caption,
    String? overlayText,
    List<String>? overlayVideos,
    PostMusic? music,
  }) = _CreateStoryDto;

  factory CreateStoryDto.fromJson(Map<String, dynamic> json) =>
      _$CreateStoryDtoFromJson(json);
}
