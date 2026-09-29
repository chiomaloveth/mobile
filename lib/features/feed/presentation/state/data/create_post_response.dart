import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response_data.dart';
import 'package:qik_talk/utilities/metadata_utils.dart';

part 'create_post_response.freezed.dart';
part 'create_post_response.g.dart';

/// Mirrors backend create-post response which may differ from feed list shape.
/// Notably: `user` may be an id string, and extra fields like `tags`/`music`
/// may or may not be present.
@freezed
class CreatePostResponse with _$CreatePostResponse {
  const factory CreatePostResponse({
    @JsonKey(name: '_id') required String id,
    String? user,
    @Default('') String content,
    @Default([]) List<String> media,
    @Default(0) int views,
    @Default([]) List<dynamic> likes,
    @Default([]) List<dynamic> shares,
    @Default([]) List<dynamic> bookmarks,
    dynamic sharedFrom,
    Music? music,
    @Default(<String>[]) List<String> tags,
    @Default('everyone') String privacy,
    required DateTime createdAt,
    required DateTime updatedAt,
    @JsonKey(name: '__v') int? v,
    @JsonKey(name: 'commentCount') @Default(0) int commentCount,
    bool? isFollowing,
    @JsonKey(name: 'id') String? legacyId,
    bool? allowComment,
    @JsonKey(name: 'overlayText') String? overlayText,
    @JsonKey(name: 'overlayVideos') List<String>? overlayVideos,
  }) = _CreatePostResponse;

  factory CreatePostResponse.fromJson(Map<String, dynamic> json) =>
      _$CreatePostResponseFromJson(_sanitizeCreatePostJson(json));
}

Map<String, dynamic> _sanitizeCreatePostJson(Map<String, dynamic> json) {
  // 1. Unwrap 'data' if present (Backend change support)
  if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
    json = Map<String, dynamic>.from(json['data'] as Map<String, dynamic>);
  }

  if (json['allowComments'] != null) {
    json['allowComment'] = json['allowComments'];
  }

  // 2. Safely map media (can contain nulls or non-string items)
  if (json['media'] is List) {
    json['media'] = (json['media'] as List)
        .where((e) => e != null)
        .map((e) => e.toString())
        .toList();
  } else {
    json['media'] = <String>[];
  }

  // tags can be missing, null, or dynamic
  if (json['tags'] is List) {
    json['tags'] = (json['tags'] as List)
        .where((e) => e != null)
        .map((e) => e.toString())
        .toList();
  }

  // URL Stitching for immediate UI feedback
  final videoUrls = <String>[];
  final rawVideos = json['overlayVideos'] ?? json['overlayVideoFiles'];
  if (rawVideos is List) {
    final list = rawVideos
        .where((e) => e != null)
        .map((e) => e.toString())
        .toList();
    json['overlayVideos'] = list;
    videoUrls.addAll(list);
  }

  final stitchedList = MetadataUtils.stitchFeedOverlays(json['overlayText'] as String?, videoUrls);
  if (stitchedList.isNotEmpty) {
    json['overlays'] = stitchedList;
  }

  return json;
}
