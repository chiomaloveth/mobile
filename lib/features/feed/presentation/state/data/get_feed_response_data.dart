import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:qik_talk/features/feed/presentation/state/data/feed_user.dart';
import 'package:qik_talk/utilities/metadata_utils.dart';

export 'package:qik_talk/features/feed/presentation/state/data/feed_user.dart';

part 'get_feed_response_data.freezed.dart';
part 'get_feed_response_data.g.dart';

@freezed
class GetFeedResponseData with _$GetFeedResponseData {
  const factory GetFeedResponseData({
    @JsonKey(name: '_id') required String id,
    required FeedUser user,
    @Default('') String content,
    @Default([]) List<String> media,
    @Default([]) List<dynamic> likes,
    @Default([]) List<dynamic> shares,
    @Default([]) List<dynamic> bookmarks,
    @Default(0) int views,
    @Default(false) bool isBookmarked,
    @Default(false) bool isFollowing,
    @JsonKey(name: 'commentCount') @Default(0) int commentCount,
    @Default([]) List<String> tags,
    @Default(0) int bookmarkCount,
    List<dynamic>? overlays,
    String? overlayText,
    List<String>? overlayVideos,

    dynamic sharedFrom,
    Music? music,
    @Default('everyone') String privacy,
    @Default(true) bool allowComment,
    required DateTime createdAt,
    required DateTime updatedAt,
    @JsonKey(name: '__v') @Default(0) int v,
  }) = _GetFeedResponseData;

  factory GetFeedResponseData.fromJson(Map<String, dynamic> json) =>
      _$GetFeedResponseDataFromJson(_sanitizeFeedJson(json));

  factory GetFeedResponseData.empty() => GetFeedResponseData(
    id: '',
    user: const FeedUser(id: '', username: '', profilePicture: ''),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

@freezed
class Music with _$Music {
  const factory Music({
    required String thirdPartyId,
    required String title,
    required String artist,
    required String audioUrl,
    String? coverImage,
  }) = _Music;

  factory Music.fromJson(Map<String, dynamic> json) => _$MusicFromJson(json);
}

/// Sanitizes feed JSON to handle null values in media array recursively
Map<String, dynamic> _sanitizeFeedJson(Map<String, dynamic> json) {
  if (json['allowComments'] != null) {
    json['allowComment'] = json['allowComments'];
  }

  // Sanitize media at current level
  if (json['media'] is List) {
    json['media'] = (json['media'] as List)
        .where((e) => e != null)
        .map((e) => e.toString())
        .toList();
  }

  // Sanitize sharedFrom if it exists and contains media
  if (json['sharedFrom'] != null && json['sharedFrom'] is Map) {
    final sharedFrom = Map<String, dynamic>.from(json['sharedFrom']);
    if (sharedFrom['media'] is List) {
      sharedFrom['media'] = (sharedFrom['media'] as List)
          .where((e) => e != null)
          .map((e) => e.toString())
          .toList();
    }
    json['sharedFrom'] = sharedFrom;
  }

  // Handle overlayVideos list for the extractUrls logic used by model Key
  final List<String> videoUrls = [];
  final rawVideoData = json['overlayVideos'] ?? json['overlayVideoFiles'];

  if (rawVideoData is List) {
    for (var item in rawVideoData) {
      if (item is String && item.isNotEmpty) {
        videoUrls.add(item);
      }
    }
  }

  // Use centralized metadata stitching
  final stitchedList = MetadataUtils.stitchFeedOverlays(json['overlayText'] as String?, videoUrls);
  if (stitchedList.isNotEmpty) {
    json['overlays'] = stitchedList;
  }

  // Final pass: ensure overlayVideos is a list of strings for the model
  if (json['overlayVideos'] != null && json['overlayVideos'] is List) {
    json['overlayVideos'] = (json['overlayVideos'] as List)
        .where((e) => e != null)
        .map((e) => e.toString())
        .toList();
  }

  return json;
}
