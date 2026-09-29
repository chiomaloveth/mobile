import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_post_dto.freezed.dart';
part 'create_post_dto.g.dart';

@freezed
class CreatePostDto with _$CreatePostDto {
  const factory CreatePostDto({
    String? content,
    List<String>? media,
    PostMusic? music,
    List<String>? tags,
    String? overlayText,
    List<String>? overlayVideos,
    @JsonKey(name: 'allowComment') bool? allowComment,
    List<String>? taggedUsers,
  }) = _CreatePostDto;


  factory CreatePostDto.fromJson(Map<String, dynamic> json) =>
      _$CreatePostDtoFromJson(json);
}

@freezed
class PostMusic with _$PostMusic {
  const factory PostMusic({
    required String thirdPartyId,
    required String title,
    required String artist,
    required String audioUrl,
    String? coverImage,
  }) = _PostMusic;

  factory PostMusic.fromJson(Map<String, dynamic> json) =>
      _$PostMusicFromJson(json);
}

