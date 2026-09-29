import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_comment_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response_data.dart';
import 'package:qik_talk/utilities/metadata_utils.dart';

part 'get_story_response_data.freezed.dart';
part 'get_story_response_data.g.dart';

@freezed
class GetStoryResponseData with _$GetStoryResponseData {
  const factory GetStoryResponseData({
    required bool success,
    required List<StoryData> data,
  }) = _GetStoryResponseData;

  factory GetStoryResponseData.fromJson(Map<String, dynamic> json) =>
      _$GetStoryResponseDataFromJson(json);
}

@freezed
class StoryData with _$StoryData {
  const factory StoryData({
    @JsonKey(name: "_id") String? id,
    MyUser? user,
    List<Update>? updates,
  }) = _StoryData;

  factory StoryData.fromJson(Map<String, dynamic> json) =>
      _$StoryDataFromJson(json);
}

@freezed
class Update with _$Update {
  const factory Update({
    @JsonKey(name: "_id") String? updateId,
    MyUser? user,
    String? media,
    String? mediaType,
    String? caption,
    List<StoryViewer>? viewers,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    @JsonKey(name: "__v") int? v,
    String? bgColor,
    int? backgroundColor,
    int? viewCount,
    String? id,
    bool? hasViewed,
    String? overlayText,
    List<String>? overlayVideos,
    List<dynamic>? overlays,
    Music? music,
  }) = _Update;

  factory Update.fromJson(Map<String, dynamic> json) =>
      _$UpdateFromJson(_sanitizeUpdateJson(json));
}

extension UpdateX on Update {
  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);
  int get calculatedViewCount => viewers?.length ?? 0;
}

@freezed
class StoryViewer with _$StoryViewer {
  const factory StoryViewer({
    @JsonKey(name: "_id") String? id,
    String? userId,
    String? username,
    String? profilePicture,
    DateTime? viewedAt,
  }) = _StoryViewer;

  factory StoryViewer.fromJson(Map<String, dynamic> json) =>
      _$StoryViewerFromJson(json);
}

Map<String, dynamic> _sanitizeUpdateJson(Map<String, dynamic> json) {
  // 1. Collect all video URLs from various possible fields
  final List<String> videoUrls = [];
  final rawVideoData = json['overlayVideos'] ?? json['overlayVideoFiles'];

  if (rawVideoData is List) {
    for (var item in rawVideoData) {
      if (item is String && item.isNotEmpty) {
        videoUrls.add(item);
      }
    }
  }

  // 2. Use centralized metadata stitching
  final metadata = MetadataUtils.parseOverlayMetadata(json['overlayText'] as String?);
  final stitched = MetadataUtils.stitchOverlayVideos(metadata, videoUrls);

  if (stitched.isNotEmpty) {
    // Stories treat each update as a single media item, so use flat list.
    json['overlays'] = stitched;
  }

  // 3. Final pass: ensure overlayVideos is a list of strings
  if (json['overlayVideos'] != null && json['overlayVideos'] is List) {
    json['overlayVideos'] = (json['overlayVideos'] as List)
        .where((e) => e != null)
        .map((e) => e.toString())
        .toList();
  }

  return json;
}
