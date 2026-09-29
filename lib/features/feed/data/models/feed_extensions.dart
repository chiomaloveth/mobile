import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response_data.dart';
import 'package:qik_talk/utilities/media_utils.dart';

/// Extension methods on [GetFeedResponseData] for UI convenience.
extension GetFeedResponseDataX on GetFeedResponseData {
  bool isLikedBy(String userId) {
    return likes.contains(userId);
  }

  bool isSharedBy(String userId) {
    return shares.contains(userId);
  }

  bool isBookmarkedBy(String userId) {
    return bookmarks.contains(userId);
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }

  bool get isVideo {
    if (media.isEmpty) return false;
    return media.any((url) => MediaUtils.isVideo(url));
  }
}
