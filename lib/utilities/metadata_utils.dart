import 'dart:convert';

class MetadataUtils {
  /// Pairs overlay metadata objects with their corresponding URLs from a separate list.
  /// 
  /// The backend often returns overlay positions/types in one JSON string (`overlayText`)
  /// and the actual video URLs in a separate list (`overlayVideos`).
  /// This function 'stitches' them together by matching the order of 'video' type overlays.
  static List<dynamic> stitchOverlayVideos(List<dynamic> metadata, List<String> urls) {
    if (metadata.isEmpty) return metadata;

    final result = <dynamic>[];
    int urlIndex = 0;

    for (var item in metadata) {
      if (item is! Map) {
        result.add(item);
        continue;
      }

      final map = Map<String, dynamic>.from(item);
      final rawType = map['type']?.toString().toLowerCase();
      final isVideo = rawType == 'video' || rawType == '2';

      if (isVideo) {
        // Skip any URLs that are actually JSON metadata strings stored by mistake
        while (urlIndex < urls.length && 
              (urls[urlIndex].startsWith('[') || urls[urlIndex].startsWith('{'))) {
          urlIndex++;
        }

        if ((map['videoUrl'] == null || map['videoUrl'].toString().isEmpty) &&
            urlIndex < urls.length) {
          final stitchedUrl = urls[urlIndex++];
          map['videoUrl'] = stitchedUrl;
          // print('✅ Stitched video overlay ${map['id']} with URL: $stitchedUrl');
        } else if (map['videoUrl'] != null) {
          // print('ℹ️ Overlay ${map['id']} already has URL: ${map['videoUrl']}');
        }
        
        // Ensure some sensible defaults if metadata is sparse
        map['fontSize'] ??= 150.0;
      }
      result.add(map);
    }

    // Handle any leftover video URLs that weren't represented in metadata
    while (urlIndex < urls.length) {
      result.add({
        'id': 'video_fallback_${DateTime.now().millisecondsSinceEpoch}_$urlIndex',
        'videoUrl': urls[urlIndex++],
        'type': 'video',
        'dx': 0.1, // Default safe position
        'dy': 0.1,
        'fontSize': 150.0,
        'isNormalized': true,
        'aspectRatio': 9 / 16,
      });
    }

    return result;
  }

  /// Extracts overlay metadata from various possible JSON formats in overlayText.
  static List<dynamic> parseOverlayMetadata(String? overlayTextStr) {
    if (overlayTextStr == null || overlayTextStr.isEmpty) return [];

    try {
      final decoded = jsonDecode(overlayTextStr);
      List<dynamic> rawMetadata = [];
      if (decoded is List) {
        rawMetadata = decoded;
      } else if (decoded is Map && decoded.containsKey('overlays')) {
        rawMetadata = decoded['overlays'] as List;
      }

      final result = <dynamic>[];
      for (var item in rawMetadata) {
        if (item is List) {
          result.addAll(item);
        } else {
          result.add(item);
        }
      }
      return result;
    } catch (e) {
      // Fallback for legacy plain text
      return [{
        'id': 'legacy_${DateTime.now().millisecondsSinceEpoch}',
        'text': overlayTextStr,
        'type': 'text',
        'dx': 0.5,
        'dy': 0.5,
        'fontSize': 24.0,
        'isNormalized': true,
      }];
    }
  }

  /// Stitch overlays preserving the nested list of lists structure (e.g. [[overlay1, overlay2], [overlay3]])
  /// where the outer index corresponds to the media item index.
  static List<List<dynamic>> stitchFeedOverlays(String? overlayTextStr, List<String> urls) {
    if (overlayTextStr == null || overlayTextStr.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(overlayTextStr);
      if (decoded is! List) {
        // Fallback if it is not a nested list
        final singleStitched = stitchOverlayVideos(parseOverlayMetadata(overlayTextStr), urls);
        return [singleStitched];
      }

      final result = <List<dynamic>>[];
      int urlIndex = 0;

      for (var group in decoded) {
        if (group is! List) {
          // If a group is not a list, treat it as a single overlay item group
          final stitchedGroup = stitchOverlayVideos([group], urls.sublist(urlIndex));
          int videoCount = stitchedGroup.where((o) => _isVideoOverlay(o)).length;
          urlIndex += videoCount;
          result.add(stitchedGroup);
          continue;
        }

        final stitchedGroup = <dynamic>[];
        for (var item in group) {
          if (item is! Map) {
            stitchedGroup.add(item);
            continue;
          }

          final map = Map<String, dynamic>.from(item);
          final rawType = map['type']?.toString().toLowerCase();
          final isVideo = rawType == 'video' || rawType == '2';

          if (isVideo) {
            while (urlIndex < urls.length && 
                  (urls[urlIndex].startsWith('[') || urls[urlIndex].startsWith('{'))) {
              urlIndex++;
            }

            if ((map['videoUrl'] == null || map['videoUrl'].toString().isEmpty) &&
                urlIndex < urls.length) {
              final stitchedUrl = urls[urlIndex++];
              map['videoUrl'] = stitchedUrl;
            }
            map['fontSize'] ??= 150.0;
          }
          stitchedGroup.add(map);
        }
        result.add(stitchedGroup);
      }

      // If there are leftover video URLs, append them to the first group or as fallback groups
      while (urlIndex < urls.length) {
        if (result.isEmpty) {
          result.add([]);
        }
        result[0].add({
          'id': 'video_fallback_${DateTime.now().millisecondsSinceEpoch}_$urlIndex',
          'videoUrl': urls[urlIndex++],
          'type': 'video',
          'dx': 0.1,
          'dy': 0.1,
          'fontSize': 150.0,
          'isNormalized': true,
          'aspectRatio': 9 / 16,
        });
      }

      return result;
    } catch (e) {
      final singleStitched = stitchOverlayVideos(parseOverlayMetadata(overlayTextStr), urls);
      return [singleStitched];
    }
  }

  static bool _isVideoOverlay(dynamic o) {
    if (o is! Map) return false;
    final rawType = o['type']?.toString().toLowerCase();
    return rawType == 'video' || rawType == '2';
  }
}
