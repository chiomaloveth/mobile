import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:qik_talk/utilities/metadata_utils.dart';

part 'create_story_response_data.freezed.dart';
part 'create_story_response_data.g.dart';

@freezed
class CreateStoryResponseData with _$CreateStoryResponseData {
  const factory CreateStoryResponseData({
    @JsonKey(name: 'success') bool? success,
    @JsonKey(name: 'data') CreateStoryData? data,
  }) = _CreateStoryResponseData;

  factory CreateStoryResponseData.fromJson(Map<String, dynamic> json) =>
      _$CreateStoryResponseDataFromJson(json);
}

@freezed
class CreateStoryData with _$CreateStoryData {
  const factory CreateStoryData({
    @JsonKey(name: 'user') String? user,
    @JsonKey(name: 'media') String? media,
    @JsonKey(name: 'mediaType') String? mediaType,
    @JsonKey(name: 'caption') String? caption,
    @JsonKey(name: '_id') String? id,
    @JsonKey(name: 'viewers') List<dynamic>? viewers,
    @JsonKey(name: 'expiresAt') String? expiresAt,
    @JsonKey(name: 'createdAt') String? createdAt,
    @JsonKey(name: 'updatedAt') String? updatedAt,
    @JsonKey(name: 'overlayText') String? overlayText,
    @JsonKey(name: 'overlayVideos') List<String>? overlayVideos,
    @JsonKey(name: '__v') int? v,
  }) = _CreateStoryData;

  factory CreateStoryData.fromJson(Map<String, dynamic> json) =>
      _$CreateStoryDataFromJson(_sanitizeCreateStoryDataJson(json));
}

Map<String, dynamic> _sanitizeCreateStoryDataJson(Map<String, dynamic> json) {
  // Handle media as List or String (consistency with Post behavior)
  if (json['media'] is List && (json['media'] as List).isNotEmpty) {
    json['media'] = json['media'][0]?.toString();
  } else if (json['media'] is! String) {
    json['media'] = null;
  }

  final videoUrls = <String>[];
  if (json['overlayVideos'] is List) {
    json['overlayVideos'] = (json['overlayVideos'] as List)
        .where((e) => e != null)
        .map((e) => e.toString())
        .toList();
    videoUrls.addAll(json['overlayVideos'] as List<String>);
  }

  // URL Stitching for stories
  final metadata = MetadataUtils.parseOverlayMetadata(json['overlayText'] as String?);
  final stitched = MetadataUtils.stitchOverlayVideos(metadata, videoUrls);

  if (stitched.isNotEmpty) {
    // Stories treat each update as a single media item, so use flat list.
    json['overlays'] = stitched;
  }

  return json;
}
