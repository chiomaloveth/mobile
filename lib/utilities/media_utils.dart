import 'package:http_parser/http_parser.dart';

class MediaUtils {
  static final List<String> videoExtensions = [
    '.mp4',
    '.mov',
    '.avi',
    '.mkv',
    '.flv',
    '.wmv',
  ];

  /// Checks if a given URL points to a video file.
  static bool isVideo(String url) {
    if (url.isEmpty) return false;
    // Clean URL of query parameters and whitespace
    final cleanUrl = url.toLowerCase().split('?').first.trim();

    // Check by extension
    bool hasVideoExtension = videoExtensions.any(
      (ext) => cleanUrl.endsWith(ext),
    );
    if (hasVideoExtension) return true;

    return false;
  }

  /// Returns a thumbnail URL if the input is a video URL.
  /// If it's not a video or not a supported provider, returns the original URL.
  static String getThumbnailUrl(String url) {
    if (url.isEmpty) return url;

    if (!isVideo(url)) return url;

    // Fallback: return the original URL if we can't transform it safely
    return url;
  }

  /// Determines the correct MediaType for a file based on its extension.
  static MediaType getMediaType(String filePath) {
    final lowerPath = filePath.toLowerCase().split('?').first.trim();

    // Videos
    if (lowerPath.endsWith('.mp4')) return MediaType('video', 'mp4');
    if (lowerPath.endsWith('.mov')) return MediaType('video', 'quicktime');
    if (lowerPath.endsWith('.avi')) return MediaType('video', 'x-msvideo');
    if (lowerPath.endsWith('.mkv')) return MediaType('video', 'x-matroska');

    // Images
    if (lowerPath.endsWith('.gif')) return MediaType('image', 'gif');
    if (lowerPath.endsWith('.png')) return MediaType('image', 'png');
    if (lowerPath.endsWith('.webp')) return MediaType('image', 'webp');
    if (lowerPath.endsWith('.heic')) return MediaType('image', 'heic');

    // Audio (for voice comments)
    if (lowerPath.endsWith('.mp3')) return MediaType('audio', 'mpeg');
    if (lowerPath.endsWith('.m4a')) return MediaType('audio', 'mp4');
    if (lowerPath.endsWith('.wav')) return MediaType('audio', 'wav');

    return MediaType('image', 'jpeg'); // Default fallback
  }
}
