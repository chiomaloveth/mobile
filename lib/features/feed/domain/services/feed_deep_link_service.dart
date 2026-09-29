import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:qik_talk/features/feed/presentation/screens/qik_flash_screen.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response_data.dart';

/// Listens for deep links of the form:
///   https://portfolio-79b32.web.app/post/<postId>
///
/// When intercepted, opens QikFlashScreen showing that specific post.
class PostDeepLinkService {
  PostDeepLinkService._();

  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _sub;

  /// Call once from main.dart after DeepLinkService.init()
  static Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    // Handle link that launched the app from a cold start
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri, navigatorKey);
      }
    } catch (_) {}

    // Handle links while app is already running
    _sub = _appLinks.uriLinkStream.listen(
      (uri) => _handleUri(uri, navigatorKey),
      onError: (_) {},
    );
  }

  static void dispose() {
    _sub?.cancel();
    _sub = null;
  }

  static void _handleUri(Uri uri, GlobalKey<NavigatorState> navigatorKey) {
    // Only handle: https://portfolio-79b32.web.app/post/<postId>
    if (uri.host != 'portfolio-79b32.web.app') return;
    if (!uri.path.startsWith('/post/')) return;

    final postId = uri.pathSegments.length >= 2 ? uri.pathSegments[1] : null;
    if (postId == null || postId.isEmpty) return;

    print('🔗 Deep link: open post with id=$postId');

    // Wait for navigator to be ready
    Future.delayed(const Duration(milliseconds: 500), () {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => QikFlashScreen(
            posts: [
              GetFeedResponseData(
                id: postId,
                user: const FeedUser(id: '', username: 'Loading...'),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            ],
            initialPostIndex: 0,
          ),
        ),
      );
    });
  }
}