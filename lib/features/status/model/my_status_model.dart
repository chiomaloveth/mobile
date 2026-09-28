// lib/features/status/model/my_status_model.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../feed/presentation/state/data/get_feed_response_data.dart'
    show Music;

class MyStatusModel {
  final User user;
  final List<Update> updates;

  MyStatusModel({required this.user, required this.updates});

  // ── Deserialize ────────────────────────────────────────────────────────────

  /// Grouped shape: { user: {...}, updates: [...] }
  factory MyStatusModel.fromJson(Map<String, dynamic> json) {
    return MyStatusModel(
      user: User.fromJson(json['user']),
      updates: (json['updates'] as List)
          .map((u) => Update.fromJson(u))
          .where((u) => !u.isExpired)
          .toList(),
    );
  }

  /// Flat shape: each item IS a status update with a user object embedded.
  /// Groups by userId so the UI (one row per user) still works.
  static List<MyStatusModel> fromFlatList(List<dynamic> flatList) {
    final Map<String, List<Update>> grouped = {};
    final Map<String, User> users = {};

    for (final item in flatList) {
      final map = item as Map<String, dynamic>;
      final update = Update.fromJson(map);
      if (update.isExpired) continue;
      final userId = update.user.id;
      users[userId] = update.user;
      grouped.putIfAbsent(userId, () => []).add(update);
    }

    return grouped.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => MyStatusModel(user: users[e.key]!, updates: e.value))
        .toList();
  }

  // ── Serialize (needed by StatusCacheService) ───────────────────────────────
  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'updates': updates.map((u) => u.toJson()).toList(),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
class User {
  final String id;
  final String profilePicture;
  final String username;

  User({
    required this.id,
    required this.profilePicture,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['_id'] ?? '',
    profilePicture: json['profilePicture'] ?? '',
    username: json['username'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'profilePicture': profilePicture,
    'username': username,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
class Viewer {
  final String id;
  final String username;
  final String profilePicture;
  final DateTime? viewedAt;

  Viewer({
    required this.id,
    required this.username,
    required this.profilePicture,
    this.viewedAt,
  });

  /// Handles every shape the backend may return:
  /// Shape 1 — plain string ID:  "699d9967..."
  /// Shape 2 — { user: "id", viewedAt, _id }  (not populated)
  /// Shape 3 — { user: { _id, username, profilePicture }, viewedAt }
  factory Viewer.fromJson(dynamic json) {
    if (json is String) {
      return Viewer(id: json, username: 'Unknown', profilePicture: '');
    }

    final map = json as Map<String, dynamic>;
    DateTime? viewedAt;
    if (map['viewedAt'] != null) {
      viewedAt = DateTime.tryParse(map['viewedAt'].toString());
    }

    if (map['user'] is String) {
      return Viewer(
        id: map['user'] as String,
        username: 'Unknown',
        profilePicture: '',
        viewedAt: viewedAt,
      );
    }

    if (map['user'] is Map) {
      final u = map['user'] as Map<String, dynamic>;
      return Viewer(
        id: u['_id'] ?? '',
        username: u['username'] ?? 'Unknown',
        profilePicture: u['profilePicture'] ?? '',
        viewedAt: viewedAt,
      );
    }

    // Flat shape: _id/username directly on the object
    return Viewer(
      id: (map['_id'] ?? '').toString(),
      username: map['username'] ?? 'Unknown',
      profilePicture: map['profilePicture'] ?? '',
      viewedAt: viewedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'username': username,
    'profilePicture': profilePicture,
    if (viewedAt != null) 'viewedAt': viewedAt!.toIso8601String(),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
class ResharedFrom {
  final String statusId;
  final String ownerId;
  final String ownerUsername;
  final String ownerProfilePicture;
  final String media;
  final String mediaType;
  final String? caption;

  ResharedFrom({
    required this.statusId,
    required this.ownerId,
    required this.ownerUsername,
    required this.ownerProfilePicture,
    required this.media,
    required this.mediaType,
    this.caption,
  });

  factory ResharedFrom.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'];
    return ResharedFrom(
      statusId: json['_id'] ?? json['statusId'] ?? '',
      ownerId: owner?['_id'] ?? '',
      ownerUsername: owner?['username'] ?? 'Unknown',
      ownerProfilePicture: owner?['profilePicture'] ?? '',
      media: json['media'] ?? '',
      mediaType: json['mediaType'] ?? 'image',
      caption: json['caption'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': statusId,
    'media': media,
    'mediaType': mediaType,
    if (caption != null) 'caption': caption,
    'owner': {
      '_id': ownerId,
      'username': ownerUsername,
      'profilePicture': ownerProfilePicture,
    },
  };
}

// ─────────────────────────────────────────────────────────────────────────────
class Update {
  final String id;
  final User user;
  final String media;
  final String _rawMediaType;
  final String? caption;
  final List<Viewer> viewers;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int backgroundColor;
  final ResharedFrom? resharedFrom;
  final String? overlayText;
  final List<String> overlayVideos;
  final Music? music;

  // ── overlays getter (unchanged from original) ──────────────────────────────
  List<dynamic> get overlays {
    if (overlayText == null || overlayText!.isEmpty) {
      if (overlayVideos.isNotEmpty) {
        debugPrint(
          "ℹ️ Story has ${overlayVideos.length} videos but no metadata. Using fallbacks.",
        );
      } else {
        return [];
      }
    }
    try {
      final decoded = overlayText != null && overlayText!.isNotEmpty
          ? jsonDecode(overlayText!)
          : [];
      List<dynamic> rawMetadata = [];
      if (decoded is List) {
        rawMetadata = decoded;
      } else if (decoded is Map && decoded.containsKey('overlays')) {
        rawMetadata = decoded['overlays'] as List;
      }

      List<dynamic> metadata = [];
      for (var item in rawMetadata) {
        if (item is List) {
          metadata.addAll(item);
        } else {
          metadata.add(item);
        }
      }

      final List<dynamic> result = [];
      int videoUrlIndex = 0;

      for (var meta in metadata) {
        if (meta is! Map) continue;
        final map = Map<String, dynamic>.from(meta);
        final isVideo = map['type'] == 'video' || map['type'] == 2;

        if (isVideo) {
          if ((map['videoUrl'] == null || map['videoUrl'].toString().isEmpty) &&
              videoUrlIndex < overlayVideos.length) {
            final stitchedUrl = overlayVideos[videoUrlIndex++];
            map['videoUrl'] = stitchedUrl;
            debugPrint(
              "✅ Stitched story overlay ${map['id']} with URL: $stitchedUrl",
            );
          } else if (map['videoUrl'] != null) {
            debugPrint(
              "ℹ️ Story overlay ${map['id']} already has URL: ${map['videoUrl']}",
            );
          }
          map['fontSize'] ??= 150.0;
        }
        result.add(map);
      }

      while (videoUrlIndex < overlayVideos.length) {
        result.add({
          'id':
              'video_fallback_${DateTime.now().millisecondsSinceEpoch}_$videoUrlIndex',
          'videoUrl': overlayVideos[videoUrlIndex++],
          'type': 'video',
          'dx': 50.0,
          'dy': 150.0,
          'fontSize': 150.0,
          'aspectRatio': null,
        });
      }

      return result;
    } catch (e) {
      debugPrint("Error decoding overlays: $e");
      return [];
    }
  }

  Update({
    required this.id,
    required this.user,
    required this.media,
    required String rawMediaType,
    this.caption,
    required this.viewers,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    required this.backgroundColor,
    this.resharedFrom,
    this.overlayText,
    this.overlayVideos = const [],
    this.music,
  }) : _rawMediaType = rawMediaType;

  // ── mediaType getter (unchanged from original) ─────────────────────────────
  String get mediaType {
    if (_rawMediaType == 'text') return 'text';
    if (_rawMediaType == 'video') return 'video';

    final isUrl = media.startsWith('http://') || media.startsWith('https://');
    if (!isUrl && media.isNotEmpty) return 'text';

    final url = media.toLowerCase();
    if (url.contains('.mp4') ||
        url.contains('.mov') ||
        url.contains('.avi') ||
        url.contains('.mkv') ||
        url.contains('.webm') ||
        url.contains('/video/upload/'))
      return 'video';

    return 'image';
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  int get viewCount => viewers.length;
  bool get isReshare => resharedFrom != null;

  // ── fromJson (unchanged from original) ────────────────────────────────────
  factory Update.fromJson(Map<String, dynamic> json) {
    final rawMediaType = (json['mediaType'] ?? '').toString();

    String media = (json['media'] ?? '').toString();
    if (rawMediaType == 'text' && media.trim().isEmpty) {
      media = (json['caption'] ?? '').toString();
    }

    debugPrint('Loading status: $rawMediaType — $media');

    final bgColorRaw = json['backgroundColor'] ?? json['bgColor'];

    return Update(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      media: media,
      rawMediaType: rawMediaType,
      caption: json['caption']?.toString(),
      viewers: (json['viewers'] as List? ?? [])
          .map((v) => Viewer.fromJson(v))
          .toList(),
      expiresAt: DateTime.parse(json['expiresAt'].toString()),
      createdAt: DateTime.parse(json['createdAt'].toString()),
      updatedAt: DateTime.parse(json['updatedAt'].toString()),
      backgroundColor: _parseInt(bgColorRaw ?? 0xFF000000),
      resharedFrom: json['resharedFrom'] != null && json['resharedFrom'] is Map
          ? ResharedFrom.fromJson(json['resharedFrom'] as Map<String, dynamic>)
          : null,
      overlayText:
          json['overlayText']?.toString() ?? json['overlays']?.toString(),
      overlayVideos: (json['overlayVideos'] as List? ?? [])
          .map((v) => v.toString())
          .toList(),
      music: json['music'] != null && json['music'] is Map
          ? Music.fromJson(json['music'] as Map<String, dynamic>)
          : null,
    );
  }

  // ── toJson (NEW — needed by StatusCacheService) ────────────────────────────
  Map<String, dynamic> toJson() => {
    '_id': id,
    'user': user.toJson(),
    'media': media,
    'mediaType': _rawMediaType,
    if (caption != null) 'caption': caption,
    'viewers': viewers.map((v) => v.toJson()).toList(),
    'expiresAt': expiresAt.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'backgroundColor': backgroundColor,
    if (resharedFrom != null) 'resharedFrom': resharedFrom!.toJson(),
    if (overlayText != null) 'overlayText': overlayText,
    if (overlayVideos.isNotEmpty) 'overlayVideos': overlayVideos,
    if (music != null) 'music': music!.toJson(),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
int _parseInt(dynamic value) {
  if (value == null) return 0xFF000000;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0xFF000000;
  return 0xFF000000;
}
